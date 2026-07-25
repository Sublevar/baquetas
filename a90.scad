use <hueco_baqueta.scad>;

distancia = 40;
ancho_baqueta = 40;
cantidad = 5;

module _solido_en(pos = [0, 0, 0], rot = [0, 0, 0], ancho = ancho_baqueta) {
  translate(pos)
    rotate(rot)
      baqueta_solida(ancho_baqueta = ancho);
}

module _hueco_en(
  pos = [0, 0, 0],
  rot = [0, 0, 0],
  tornillos = 2,
  profundidad = 20,
  largo_hueco = ancho_baqueta,
  desface_centro = [0, 0, 0]
) {
  translate(pos)
    rotate(rot)
      hueco_baqueta(
        cantidad_tornillos = tornillos,
        profundidad_pieza = profundidad,
        largo_hueco_principal = largo_hueco,
        desface_centro = desface_centro
      );
}

// Hueco pasante seguro: fuerza largo_hueco_principal = ancho local de la pieza.
module _hueco_pasante_en(
  pos = [0, 0, 0],
  rot = [0, 0, 0],
  ancho = ancho_baqueta,
  tornillos = 2,
  profundidad = 20,
  desface_centro = [0, 0, 0]
) {
  _hueco_en(
    pos = pos,
    rot = rot,
    tornillos = tornillos,
    profundidad = profundidad,
    largo_hueco = ancho,
    desface_centro = desface_centro
  );
}

function _contiene(lista, valor) = len(search(valor, lista)) > 0;

function _debe_rotar(i, total, modo, indices, n_extremos) =
  modo == "ninguno" ? false :
  modo == "todos" ? true :
  modo == "alternar" ? i % 2 == 0 :
  modo == "indices" ? _contiene(indices, i) :
  modo == "extremos" ? (i < n_extremos || i >= total - n_extremos) :
  false;

function _angulo_indexado(i, total, rot_total, modo, indices, n_extremos) =
  _debe_rotar(i, total, modo, indices, n_extremos)
  ? (total > 1 ? (rot_total / (total - 1)) * i : 0)
  : 0;

module junta_angular(
  dist = distancia,
  angulo = 90,
  ancho = ancho_baqueta,
  tornillos = 2,
  profundidad = 20
) {
  rot_fijo = [0, 0, 90];
  rot_variable = [0, angulo, 90];

  difference() {
    hull() {
      _solido_en([0, 0, 0], rot_fijo, ancho);
      _solido_en([dist, 0, 0], rot_variable, ancho);
    }

    _hueco_pasante_en([0, 0, 0], rot_fijo, ancho, tornillos, profundidad);
    _hueco_pasante_en([dist, 0, 0], rot_variable, ancho, tornillos, profundidad);
  }
}

module junta_T(
  dist_ramal = ancho_baqueta,
  ancho = 60,
  tornillos_principal = 2,
  tornillos_ramal = 1,
  profundidad = 20,
  // Desfase local en Z; tras la rotacion interna del hueco termina corrido en X.
  desface_principal = [0, 0, -5]
) {
  difference() {
    hull() {
      _solido_en([0, 0, 0], [0, -90, 0], ancho);
      _solido_en([dist_ramal, 0, 0], [0, 0, 0], ancho);
    }

    _hueco_pasante_en([0, 0, 0], [0, -90, 0], ancho, tornillos_principal, profundidad, desface_principal);
    _hueco_pasante_en([dist_ramal, 0, 0], [0, 0, 0], ancho, tornillos_ramal, profundidad);
  }
}

module junta_cruz(
  ancho = 60,
  tornillos_eje_a = 2,
  tornillos_eje_b = 4,
  profundidad = 20
) {
  difference() {
    hull() {
      _solido_en([0, 0, 0], [0, -90, 0], ancho);
      _solido_en([0, 0, 0], [0, 0, 90], ancho);
    }

    _hueco_pasante_en([0, 0, 0], [0, -90, 0], ancho, tornillos_eje_a, profundidad);
    _hueco_pasante_en([0, 0, 0], [0, 0, 90], ancho, tornillos_eje_b, profundidad);
  }
}

module junta_array(
  cant = cantidad,
  paso = distancia,
  rot_total = 90,
  modo_rotacion = "todos",
  indices_rotacion = [0],
  n_extremos = 1,
  rot_base = [0, -90, 90],
  ancho = ancho_baqueta,
  tornillos = 2,
  profundidad = 20
) {
  difference() {
    hull() {
      for (i = [0 : cant - 1]) {
        ang = _angulo_indexado(i, cant, rot_total, modo_rotacion, indices_rotacion, n_extremos);
        _solido_en([paso * i, 0, 0], [rot_base[0], rot_base[1] + ang, rot_base[2]], ancho);
      }
    }

    for (i = [0 : cant - 1]) {
      ang = _angulo_indexado(i, cant, rot_total, modo_rotacion, indices_rotacion, n_extremos);
      _hueco_pasante_en([paso * i, 0, 0], [rot_base[0], rot_base[1] + ang, rot_base[2]], ancho, tornillos, profundidad);
    }
  }
}

module junta_matriz(
  dim = [3, 3],
  paso = [distancia, distancia],
  rot_total = 90,
  modo_rotacion = "alternar",
  indices_rotacion = [0],
  n_extremos = 1,
  eje_rotacion = "x",
  ancho = ancho_baqueta,
  tornillos = 2,
  profundidad = 20
) {
  nx = max(1, dim[0]);
  ny = max(1, dim[1]);

  difference() {
    union() {
      for (y = [0 : ny - 1]) {
        for (x = [0 : nx - 2]) {
          ang_a = eje_rotacion == "y"
            ? _angulo_indexado(y, ny, rot_total, modo_rotacion, indices_rotacion, n_extremos)
            : _angulo_indexado(x, nx, rot_total, modo_rotacion, indices_rotacion, n_extremos);
          ang_b = eje_rotacion == "y"
            ? _angulo_indexado(y, ny, rot_total, modo_rotacion, indices_rotacion, n_extremos)
            : _angulo_indexado(x + 1, nx, rot_total, modo_rotacion, indices_rotacion, n_extremos);

          hull() {
            _solido_en([x * paso[0], y * paso[1], 0], [0, -90 + ang_a, 90], ancho);
            _solido_en([(x + 1) * paso[0], y * paso[1], 0], [0, -90 + ang_b, 90], ancho);
          }
        }
      }

      for (y = [0 : ny - 2]) {
        for (x = [0 : nx - 1]) {
          ang_a = eje_rotacion == "y"
            ? _angulo_indexado(y, ny, rot_total, modo_rotacion, indices_rotacion, n_extremos)
            : _angulo_indexado(x, nx, rot_total, modo_rotacion, indices_rotacion, n_extremos);
          ang_b = eje_rotacion == "y"
            ? _angulo_indexado(y + 1, ny, rot_total, modo_rotacion, indices_rotacion, n_extremos)
            : _angulo_indexado(x, nx, rot_total, modo_rotacion, indices_rotacion, n_extremos);

          hull() {
            _solido_en([x * paso[0], y * paso[1], 0], [0, -90 + ang_a, 90], ancho);
            _solido_en([x * paso[0], (y + 1) * paso[1], 0], [0, -90 + ang_b, 90], ancho);
          }
        }
      }
    }

    for (y = [0 : ny - 1]) {
      for (x = [0 : nx - 1]) {
        ang = eje_rotacion == "y"
          ? _angulo_indexado(y, ny, rot_total, modo_rotacion, indices_rotacion, n_extremos)
          : _angulo_indexado(x, nx, rot_total, modo_rotacion, indices_rotacion, n_extremos);
        _hueco_pasante_en([x * paso[0], y * paso[1], 0], [0, -90 + ang, 90], ancho, tornillos, profundidad);
      }
    }
  }
}

module junta(
  tipo = "angular",
  dim = [3, 3],
  cant = cantidad,
  paso = distancia,
  paso_matriz = [distancia, distancia],
  rot_total = 90,
  modo_rotacion = "todos",
  indices_rotacion = [0],
  n_extremos = 1,
  ancho = ancho_baqueta
) {
  if (tipo == "angular") {
    junta_angular(ancho = ancho);
  } else if (tipo == "T") {
    junta_T(ancho = ancho);
  } else if (tipo == "cruz") {
    junta_cruz(ancho = ancho);
  } else if (tipo == "array") {
    junta_array(
      cant = cant,
      paso = paso,
      rot_total = rot_total,
      modo_rotacion = modo_rotacion,
      indices_rotacion = indices_rotacion,
      n_extremos = n_extremos,
      ancho = ancho
    );
  } else if (tipo == "matriz") {
    junta_matriz(
      dim = dim,
      paso = paso_matriz,
      rot_total = rot_total,
      modo_rotacion = modo_rotacion,
      indices_rotacion = indices_rotacion,
      n_extremos = n_extremos,
      ancho = ancho
    );
  } else {
    echo(str("Tipo no soportado: ", tipo));
  }
}

// ====================================================================
// EJEMPLOS
// modo_rotacion: "ninguno" | "todos" | "alternar" | "indices" | "extremos"
// Nota: para geometria con giro, suele funcionar mejor junta_array que junta_matriz.
// ====================================================================

module ejemplos_tipos() {
  // 1) Angular por defecto: 90 grados
  translate([0, 0, 0])
    junta_angular();

  // 2) Angular variable: mismo modulo, otro angulo
  translate([90, 0, 0])
    junta_angular(angulo = 45);

  // 3) Junta en T
  translate([0, 100, 0])
    junta_T(ancho = 60, tornillos_ramal = 1);

  // 4) Junta cruz
  translate([100, 100, 0])
    junta_cruz(ancho = 60, tornillos_eje_b = 4);

  // 5) Array recto (sin rotaciones)
  translate([0, 220, 0])
    junta_array(
      rot_total = 0,
      modo_rotacion = "ninguno"
    );

  // 6) Array con rotaciones (ideal para variar sin bloquear huecos)
  translate([0, 320, 0])
    junta_array(
      rot_total = 90,
      modo_rotacion = "alternar"
    );
}

// Activa la galeria de ejemplos
ejemplos_tipos();
//array con rotacion y el angula ( ver juntas.scad
junta_matriz();// falla la matriz
 