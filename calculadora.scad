include <config.scad>
use <hueco_baqueta.scad>
use <utils/trigonometria.scad>
include <utils/flexion.scad>

/* ============================================================
   CALCULADORA DE DIAGONALES, CRUCES Y TRIPODES
   No genera geometria: imprime un informe con los largos de varilla
   y los angulos para los acoples. Se usa desde la linea de comandos:

     ./calcular.sh diagonal dx=600 dz=400
     ./calcular.sh diagonal angulo=40 dx=600
     ./calcular.sh cruz     dx=800 dz=600
     ./calcular.sh tripode  altura=700 apertura=20 patas=3
     ./calcular.sh flexible d_min=22 d_max=24 ovalidad=0.5 precarga=0.3

   modo "diagonal": un puntal entre un POSTE vertical (nodo A) y un
        TRAVESANO horizontal (nodo B).
          dx = distancia horizontal entre nodos, dz = diferencia de altura.
          Se puede dar (dx y dz) o (angulo y uno de los dos).
   modo "cruz": las dos diagonales de un marco rectangular dx x dz
        (distancias entre nodos, de eje a eje).
   modo "tripode": patas de un pie_tripode, altura = del nodo al piso.
   modo "flexible": acople sin tornillo (sin_tornillo.scad). Dado el rango de
        diametros del palo, informa la flecha de cada brazo, la deformacion en
        la raiz frente al limite y el agarre axial estimado. Los valores de
        fuerza son ESTIMACIONES (ver supuestos en utils/flexion.scad).

   Hipotenusa = largo entre ejes = adyacente / cos(angulo).
   Largo a cortar = largo entre ejes - fondo de un hueco - fondo del otro
   (la varilla apoya en el fondo ciego de cada acople).

   El diametro entra en: boca minima de cada acople, fondo minimo del hueco
   (pared entre huecos) y desfase entre las dos varillas de una cruz.
   ============================================================ */

modo              = "diagonal";    // "diagonal" | "cruz" | "tripode" | "flexible"
dx                = 0;             // mm
dz                = 0;             // mm
angulo            = 0;             // grados desde la horizontal (diagonal/cruz)
altura            = 0;             // mm, nodo -> piso (tripode)
apertura          = 25;            // grados desde la vertical (tripode)
patas             = 3;
profundidad_hueco = 45;            // de los acoples
piso_punta        = 5;             // macizo bajo el hueco en punta_pata
luz_cruz          = 2;             // luz entre las dos varillas de una cruz
pared             = _pared_min;

// --- modo flexible ---
d_min             = _palo_min;            // diametro nominal del palo mas fino (mm)
d_max             = _palo_max;            // diametro nominal del palo mas grueso (mm)
ovalidad          = _palo_ovalidad;           // margen por palo no simetrico, a cada lado (mm)
precarga          = _palo_precarga;           // apriete radial sobre el palo mas fino (mm)
n_brazos          = 3;
espesor_brazo     = _palo_espesor_brazo;           // radial (mm); >= 2 lineas del pico
largo_flex        = 30;            // largo de la zona flexible = ancho del brazo (mm)
ancho_poste       = 4;
ancho_ranura      = 1.6;

g   = grosor_baqueta(_diametro, _holgura, _familia_tuerca, _subtipo_tuerca, _medida_tornillo);
r_h = (_diametro + _holgura) / 2;

function boca_minima(phi) = max(fondo_minimo(r_h, pared, phi) + profundidad_hueco, boca_libre(g, phi));

module nodo(nombre, phi) {
    f = fondo_minimo(r_h, pared, phi);
    echo(str("  ", nombre, ": angulo entre ejes = ", r1(phi), " grados | fondo = ", r1(f),
             " mm | boca minima (distancia_pieza) = ", r1(boca_minima(phi)), " mm"));
}

module informe_diagonal(dx, dz, angulo, titulo = "Diagonal") {
    alfa = (dx > 0 && dz > 0) ? angulo_catetos(dx, dz) : angulo;
    ok   = alfa > 0 && alfa < 90 && (dx > 0 || dz > 0);
    assert(ok, "calculadora: dar (dx y dz) o (angulo entre 0 y 90 y dx o dz)");
    dx_ = dx > 0 ? dx : dz / tan(alfa);
    dz_ = dz > 0 ? dz : dx * tan(alfa);
    L   = hipotenusa(dx_, dz_);
    phi_a = 90 - alfa;      // poste vertical (A) vs diagonal
    phi_b = alfa;           // travesano horizontal (B) vs diagonal
    fa  = fondo_minimo(r_h, pared, phi_a);
    fb  = fondo_minimo(r_h, pared, phi_b);
    corte = largo_corte(L, fa, fb);
    echo(str("== ", titulo, " =="));
    echo(str("  catetos: dx = ", r1(dx_), " mm, dz = ", r1(dz_), " mm | angulo desde la horizontal = ", r1(alfa), " grados"));
    echo(str("  largo entre ejes (hipotenusa = dx / cos) = ", r1(L), " mm"));
    nodo("nodo A (en poste vertical) ", phi_a);
    nodo("nodo B (en travesano)      ", phi_b);
    echo(str("  >>> VARILLA A CORTAR = ", r1(corte), " mm  (apoyada en el fondo de ambos huecos)"));
    echo(str("  tramo visible entre bocas = ", r1(L - boca_minima(phi_a) - boca_minima(phi_b)), " mm"));
    if (corte <= 0) echo("  ADVERTENCIA: los acoples ocupan todo el tramo, no queda varilla");
}

module informe_cruz(dx, dz) {
    informe_diagonal(dx, dz, 0, "Cruz: cada diagonal");
    echo(str("  cruce: separar las dos varillas en planos paralelos, ejes a >= ",
             r1(desfase_cruz(_diametro, luz_cruz)), " mm (diametro ", _diametro, " + luz ", luz_cruz, ")"));
    echo("  las dos diagonales miden lo mismo (rectangulo), un solo largo de corte");
}

module informe_tripode(altura, apertura, patas) {
    assert(altura > 0 && apertura > 0 && apertura < 90, "calculadora: dar altura y apertura (0-90)");
    L      = largo_por_coseno(altura, apertura);
    f_hub  = max(fondo_radial(r_h, pared, apertura, patas), fondo_sobre_plano(r_h, pared, apertura));
    t_b    = fondo_sobre_plano(r_h, piso_punta, apertura);
    corte  = largo_corte(L, f_hub, t_b);
    radio  = altura * tan(apertura);
    echo(str("== Tripode: ", patas, " patas, apertura ", apertura, " grados, nodo a ", altura, " mm del piso =="));
    echo(str("  largo de pata entre ejes (hipotenusa = altura / cos) = ", r1(L), " mm"));
    echo(str("  hub: fondo de pata = ", r1(f_hub), " mm | boca (distancia_pieza) = ", r1(f_hub + profundidad_hueco), " mm"));
    echo(str("  punta: fondo del hueco sobre el piso, por el eje = ", r1(t_b), " mm"));
    echo(str("  >>> VARILLA A CORTAR (cada pata) = ", r1(corte), " mm"));
    visible = L - (f_hub + profundidad_hueco) - (t_b + profundidad_hueco);
    echo(str("  tramo visible entre bocas = ", r1(visible), " mm"));
    if (visible <= 0)
        echo("  ADVERTENCIA: hub y punta se tocan o se solapan; subir la altura o bajar la apertura");
    echo(str("  huella: radio de apoyo = ", r1(radio), " mm | distancia entre puntas vecinas = ",
             r1(2 * radio * sin(180 / patas)), " mm"));
}

module informe_flexible() {
    g     = geom_flex(d_min, d_max, ovalidad, precarga, espesor_brazo);
    r_med = g[1] + espesor_brazo / 2;
    L     = largo_arco(r_med, n_brazos, ancho_poste, ancho_ranura);
    b     = largo_flex;
    d_pre = g[3]; d_mx = g[4];
    eps   = deformacion_brazo(espesor_brazo, L, d_mx);
    Fp    = fuerza_brazo(b, espesor_brazo, L, d_pre);
    Fm    = fuerza_brazo(b, espesor_brazo, L, d_mx);
    wall  = g_ext() / 2 - g[6];
    echo("== Acople sin tornillo (brazos tangenciales) ==");
    echo(str("  rango de diseño del palo: ", d_min - ovalidad, " a ", d_max + ovalidad,
             " mm  (nominal ", d_min, "-", d_max, " + ovalidad ", ovalidad, ")"));
    echo(str("  diametro libre entre resaltes en reposo = ", r1(2 * g[0]), " mm | agujero interior = ", r1(2 * g[1]), " mm"));
    echo(str("  flecha de cada resalte: ", r1(d_pre), " mm con el palo mas fino, ", r1(d_mx), " mm con el mas grueso"));
    echo(str("  espacio detras del brazo = ", r1(g[5]), " mm | radio del alojamiento = ", r1(g[6]),
             " mm | camisa restante = ", r1(wall), " mm"));
    echo(str("  ", n_brazos, " brazos de ", r1(L), " mm de arco, ", espesor_brazo, " mm de espesor, ", b, " mm de ancho"));
    echo(str("  deformacion en la raiz con el palo mas grueso = ", r1(eps * 100), " %  (limite supuesto ", eps_max * 100, " %)"));
    echo(str("  fuerza por brazo: ", r1(Fp), " N (palo fino) a ", r1(Fm), " N (palo grueso)"));
    echo(str("  >>> AGARRE AXIAL ESTIMADO (mu = ", mu, "): ", r1(agarre(n_brazos, b, espesor_brazo, L, d_pre)), " N con el palo mas fino, ",
             r1(agarre(n_brazos, b, espesor_brazo, L, d_mx)), " N con el mas grueso"));
    echo(str("  relacion de agarre grueso/fino = ", r1(d_mx / d_pre), " : 1"));
    if (eps > eps_max)
        echo(str("  ADVERTENCIA: deformacion ", r1(eps * 100), " % > ", eps_max * 100, " %. Brazo minimo para ese limite: ",
                 r1(largo_brazo_min(espesor_brazo, d_mx)), " mm (menos brazos, menos espesor o menos precarga/ovalidad)"));
    if (wall < pared)
        echo(str("  ADVERTENCIA: camisa de ", r1(wall), " mm < pared minima ", pared, " mm"));
    echo("  alternativas de cantidad de brazos (largo de arco / deformacion):");
    for (n = [3 : 6]) {
        Ln = largo_arco(r_med, n, ancho_poste, ancho_ranura);
        echo(str("    ", n, " brazos: ", r1(Ln), " mm / ", r1(deformacion_brazo(espesor_brazo, Ln, d_mx) * 100), " %"));
    }
}
function g_ext() = grosor_baqueta(_diametro, _holgura, _familia_tuerca, _subtipo_tuerca, _medida_tornillo);

if (modo == "diagonal")     informe_diagonal(dx, dz, angulo);
else if (modo == "cruz")    informe_cruz(dx, dz);
else if (modo == "tripode") informe_tripode(altura, apertura, patas);
else if (modo == "flexible") informe_flexible();
else echo(str("calculadora: modo desconocido '", modo, "'"));
