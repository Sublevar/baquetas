include <config.scad>
use <hueco_baqueta.scad>
use <utils/acople.scad>
use <utils/flexion.scad>
use <utils/trigonometria.scad>

/* ============================================================
   ACOPLES SIN TORNILLO PARA PALOS DE DIAMETRO VARIABLE
   Pensado para palos de escoba: 22 a 24 mm y, ademas, no del todo
   simetricos. En lugar de un hueco rigido, el acople sujeta el palo
   con N brazos tangenciales flexibles (por defecto 3, centrado a 3
   puntos). Cada brazo cede por su cuenta, asi que copia el diametro
   local aunque el palo sea ovalado.

     d_min, d_max : diametros nominales del palo (mm)
     ovalidad     : margen extra a cada lado para palos no simetricos
     precarga     : cuanto aprieta (radial, mm) el palo mas fino

   Geometria (corte perpendicular al eje), por brazo:
     - brazo = tira curva de espesor `espesor_brazo`, concentrica con el hueco
     - poste = macizo que une el brazo con la camisa por un solo extremo
     - ranura = corte entre la punta del brazo y el poste siguiente
     - resalte = tope redondo en la punta que sobresale hacia el centro
     - alojamiento = espacio libre detras del brazo para que ceda
   El brazo flexa dentro del plano de capa: IMPRIMIR CON EL EJE VERTICAL Y LA
   BOCA HACIA ARRIBA. Un voladizo que flexa en Z pierde ~50 % de elongacion.

   Mismo contrato que acople_cuerpo / acople_hueco (eje X, boca en x = largo),
   asi que se puede intercambiar en cualquier pieza:
       difference() { acople_cuerpo(largo = L); hueco_flexible(largo = L); }
   ============================================================ */

/* ---------- PERFIL 2D DEL VACIO (zona flexible) ---------- */
module sector(r1, r2, a0, a1, n = 24)
    polygon(concat(
        [for (i = [0 : n])      r2 * [cos(a0 + (a1 - a0) * i / n), sin(a0 + (a1 - a0) * i / n)]],
        [for (i = [n : -1 : 0]) r1 * [cos(a0 + (a1 - a0) * i / n), sin(a0 + (a1 - a0) * i / n)]]
    ));

module perfil_vacio(g, n_brazos, espesor_brazo, ancho_ranura, ancho_poste, radio_tope) {
    r_tope = g[0]; r_in = g[1]; r_a = g[2]; r_sh = g[6];
    P       = 360 / n_brazos;
    a_post  = ancho_poste  / r_a  * 180 / PI;
    a_slit  = ancho_ranura / r_in * 180 / PI;
    a_tope  = radio_tope   / r_in * 180 / PI;
    difference() {
        circle(r = r_sh, $fn = 96);
        for (i = [0 : n_brazos - 1]) {
            s = i * P;
            sector(r_in, r_a, s, s + P - a_slit);                       // brazo
            sector(r_a - 0.2, r_sh + 0.5, s, s + a_post);               // poste
            // resalte redondo en la punta, apoyado en la cara interior del brazo
            a_c = s + P - a_slit - a_tope;
            translate([(r_tope + radio_tope) * cos(a_c), (r_tope + radio_tope) * sin(a_c)])
                circle(r = radio_tope, $fn = 32);
        }
    }
}

/* ---------- HUECO (lo que se resta) ----------
   Zona flexible en los ultimos `largo_flex` mm junto a la boca; mas adentro,
   agujero recto hasta `profundidad_hueco`. Entrada conica para guiar el palo. */
module hueco_flexible(
    largo             = 60,
    profundidad_hueco = 45,
    largo_flex        = 30,
    d_min             = _palo_min,
    d_max             = _palo_max,
    ovalidad          = _palo_ovalidad,
    precarga          = _palo_precarga,
    n_brazos          = 3,
    espesor_brazo     = _palo_espesor_brazo,
    ancho_ranura      = 1.6,
    ancho_poste       = 4,
    radio_tope        = 2,
    angulo_entrada    = 25,
    d_ext             = 0,      // diametro exterior del cuerpo; 0 = el de config
    pared             = _pared_min,
    pasante           = false   // true: hueco recto de lado a lado (collar)
) {
    g_ext = d_ext > 0 ? d_ext
          : grosor_baqueta(_diametro, _holgura, _familia_tuerca, _subtipo_tuerca, _medida_tornillo);
    g  = geom_flex(d_min, d_max, ovalidad, precarga, espesor_brazo);
    r_tope = g[0]; r_in = g[1]; r_sh = g[6];
    lead = (r_in - r_tope) / tan(angulo_entrada);

    if (r_sh > g_ext / 2 - pared)
        echo(str("ADVERTENCIA hueco_flexible: el alojamiento (radio ", r1(r_sh), ") deja una camisa de ",
                 r1(g_ext / 2 - r_sh), " mm < ", pared, " mm. Subir d_ext o bajar espesor/ovalidad/precarga"));
    if (largo_flex > profundidad_hueco && !pasante)
        echo("ADVERTENCIA hueco_flexible: largo_flex mayor que profundidad_hueco");

    // zona flexible
    translate([largo - largo_flex, 0, 0]) rotate([0, 90, 0])
        linear_extrude(height = largo_flex + 1)
            perfil_vacio(g, n_brazos, espesor_brazo, ancho_ranura, ancho_poste, radio_tope);
    // agujero recto hasta el fondo (o de lado a lado)
    x_fondo = pasante ? -1 : largo - profundidad_hueco;
    translate([x_fondo, 0, 0]) rotate([0, 90, 0])
        cylinder(r = r_in, h = largo - largo_flex - x_fondo + 0.01, $fn = 64);
    // entrada conica
    translate([largo - lead, 0, 0]) rotate([0, 90, 0])
        cylinder(r1 = r_tope, r2 = r_in, h = lead + 0.01, $fn = 64);
}

// cuerpo exterior con los valores de config (sigue al perfil de impresion)
module cuerpo_flex(largo)
    acople_cuerpo(
        largo = largo, diametro = _diametro, holgura = _holgura, poly_n = _poly_n,
        familia_tuerca = _familia_tuerca, subtipo_tuerca = _subtipo_tuerca,
        medida_tornillo = _medida_tornillo
    );

/* ---------- ACOPLE CIEGO (palo entra por la boca) ---------- */
module acople_flexible(
    largo             = 70,
    profundidad_hueco = 55,
    largo_flex        = 30,
    d_min = _palo_min, d_max = _palo_max, ovalidad = _palo_ovalidad, precarga = _palo_precarga,
    n_brazos = 3, espesor_brazo = _palo_espesor_brazo
) {
    difference() {
        cuerpo_flex(largo);
        hueco_flexible(
            largo = largo, profundidad_hueco = profundidad_hueco, largo_flex = largo_flex,
            d_min = d_min, d_max = d_max, ovalidad = ovalidad, precarga = precarga,
            n_brazos = n_brazos, espesor_brazo = espesor_brazo
        );
    }
}

/* ---------- AGUJEROS REUTILIZABLES (para armar otras piezas) ----------
   Eje X, desde x = 0 hasta x = largo. Se restan de cualquier cuerpo:
       difference() { cuerpo(); agujero_flex_pasante(largo = L); }
   pasante: zona flexible en los dos extremos y agujero recto en el medio.
   ciego:   zona flexible en la boca (x = largo) y fondo macizo.                  */
module agujero_flex_pasante(largo = 80, largo_flex = 28) {
    hueco_flexible(largo = largo, largo_flex = largo_flex, pasante = true);
    translate([largo, 0, 0]) mirror([1, 0, 0])
        hueco_flexible(largo = largo, largo_flex = largo_flex, profundidad_hueco = largo);
}
module agujero_flex_ciego(largo = 70, profundidad_hueco = 55, largo_flex = 30) {
    hueco_flexible(largo = largo, profundidad_hueco = profundidad_hueco, largo_flex = largo_flex);
}

/* ---------- COLLAR DESLIZANTE (pasante, zona flexible en cada extremo) ---------- */
module collar_flexible(
    largo      = 80,
    largo_flex = 28,
    d_min = _palo_min, d_max = _palo_max, ovalidad = _palo_ovalidad, precarga = _palo_precarga,
    n_brazos = 3, espesor_brazo = _palo_espesor_brazo
) {
    difference() {
        cuerpo_flex(largo);
        hueco_flexible(largo = largo, largo_flex = largo_flex, pasante = true,
                       d_min = d_min, d_max = d_max, ovalidad = ovalidad, precarga = precarga,
                       n_brazos = n_brazos, espesor_brazo = espesor_brazo);
        // segunda zona flexible, espejada, en el otro extremo
        translate([largo, 0, 0]) mirror([1, 0, 0])
            hueco_flexible(largo = largo, largo_flex = largo_flex, profundidad_hueco = largo, pasante = false,
                           d_min = d_min, d_max = d_max, ovalidad = ovalidad, precarga = precarga,
                           n_brazos = n_brazos, espesor_brazo = espesor_brazo);
    }
}

/* ---------- TAPON (cierra el extremo de un palo) ---------- */
module tapon_flexible(
    largo = 50, profundidad_hueco = 40, largo_flex = 26,
    d_min = _palo_min, d_max = _palo_max, ovalidad = _palo_ovalidad, precarga = _palo_precarga
) {
    acople_flexible(largo = largo, profundidad_hueco = profundidad_hueco, largo_flex = largo_flex,
                    d_min = d_min, d_max = d_max, ovalidad = ovalidad, precarga = precarga);
}

/* ---------- CUÑA DE AJUSTE ----------
   Se mete por la boca, en el alojamiento detras de un brazo, y lo empuja
   hacia el palo: sube el agarre sin cambiar de pieza. Ahusada y con cabeza
   de tope. Es una ayuda, no un mecanismo calculado: probarla con la prueba. */
module cuna_ajuste(
    largo_flex    = 30,
    d_min = _palo_min, d_max = _palo_max, ovalidad = _palo_ovalidad, precarga = _palo_precarga, espesor_brazo = _palo_espesor_brazo,
    ancho         = 6,
    espesor_punta = 0.8
) {
    g  = geom_flex(d_min, d_max, ovalidad, precarga, espesor_brazo);
    e1 = g[5] - 0.3;            // espesor en la cabeza: casi todo el alojamiento
    L  = largo_flex - 2;
    // cuña imprimible plana: espesor crece de la punta (x=0) a la cabeza (x=L)
    rotate([90, 0, 0]) linear_extrude(height = ancho, center = true)
        polygon([[0, 0], [L, 0], [L, e1], [0, espesor_punta]]);
    // cabeza de tope
    translate([L, -ancho / 2 - 1.5, -1]) cube([3, ancho + 3, e1 + 2]);
}

/* ---------- CALIBRE DE PALO ----------
   Placa con agujeros de 21.5 a 25 mm para medir el palo real (pasa / no pasa)
   y ver su ovalidad girandolo. */
module calibre_palo(
    d_ini = 21.5, d_fin = 25.0, paso = 0.5,
    espesor = 6, margen = 7,
    etiquetas = true
) {
    n = round((d_fin - d_ini) / paso) + 1;
    ds = [for (i = [0 : n - 1]) d_ini + i * paso];
    sep = d_fin + margen;
    difference() {
        translate([-sep / 2, -sep / 2 - 6, 0]) cube([sep * n, sep + 6, espesor]);
        for (i = [0 : n - 1]) translate([i * sep, 0, -1]) cylinder(d = ds[i], h = espesor + 2, $fn = 96);
        if (etiquetas)
            for (i = [0 : n - 1])
                translate([i * sep, -sep / 2 - 1.5, espesor - 0.6])
                    linear_extrude(1) text(str(ds[i]), size = 4, halign = "center", valign = "center");
    }
}

/* ---------- PRUEBA DE AGARRE ----------
   Cuatro tramos cortos con distinta precarga (0.1 / 0.25 / 0.4 / 0.6 mm), con
   1, 2, 3 y 4 muescas en el borde de la boca para reconocerlos. Mismos brazos y
   resaltes que la pieza final: probar con el palo real cual agarra como se quiere.
   Imprimir de pie, boca hacia arriba. */
module prueba_flexible(
    precargas = [0.1, 0.25, 0.4, 0.6],
    largo = 34, largo_flex = 24,
    d_min = _palo_min, d_max = _palo_max, ovalidad = _palo_ovalidad
) {
    g = grosor_baqueta(_diametro, _holgura, _familia_tuerca, _subtipo_tuerca, _medida_tornillo);
    for (i = [0 : len(precargas) - 1])
        translate([0, i * (g + 6), 0]) rotate([0, -90, 0])   // eje vertical, boca arriba
            difference() {
                cuerpo_flex(largo);
                hueco_flexible(largo = largo, profundidad_hueco = largo - 3, largo_flex = largo_flex,
                               d_min = d_min, d_max = d_max, ovalidad = ovalidad, precarga = precargas[i]);
                // marca de precarga: i+1 muescas en el borde de la boca
                for (k = [0 : i])
                    translate([largo - 3, 0, 0]) rotate([k * 22, 0, 0])
                        translate([0, g / 2 - 1.5, -1.2]) cube([3.2, 3, 2.4]);
            }
}

/* ============================================================
   DEMO
   ============================================================ */

// Acople ciego, de pie (eje vertical, boca arriba)
rotate([0, -90, 0]) acople_flexible();

// Collar deslizante
translate([100, 0, 0]) rotate([0, -90, 0]) collar_flexible();

// Cuña de ajuste
translate([170, 0, 0]) cuna_ajuste();

// Calibre de palo
translate([0, 130, 0]) calibre_palo();

// Prueba de agarre
translate([0, 250, 0]) prueba_flexible();
