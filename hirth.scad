use <hueco_baqueta.scad>
use <utils/acople.scad>

/* ============================================================
   JUNTA HIRTH
   Dos mitades con dientes radiales (acoplamiento Hirth) y un
   tornillo central. Cada mitad lleva un acople ciego para una
   baqueta. Aflojando el tornillo central se gira una mitad de a
   un diente (360/n_dientes grados) y se vuelve a apretar:
   la baqueta queda fijada en el angulo elegido.

   Las dos baquetas quedan en planos paralelos y giran alrededor
   del eje Z. La mitad B se da vuelta (rotate 180 en X) para
   enfrentarla a la A.

   UN SOLO SCRIPT, seis modos (junta_hirth(modo = ...)):
     "tope"         dientes hundidos dentro de una pared de tope (diseno original),
                    con muescas en la otra mitad para que los palos no choquen.
     "cilindros"    cilindros macizos (alto = radio del acople, eje del palo a la altura de los
                    dientes), sin pared, sin bolsillo y sin muescas. Hull + cilindro que
                    niega el espacio de los dientes + union de los dientes. Los palos solo
                    quedan libres entre 150 y 210 grados.
     "cilindros_90" igual, pero el cilindro que niega el espacio sube a radio + 10 mm, lo
                    que recorta los flancos del hull sobre el disco: los palos quedan libres
                    desde 90 hasta 270 grados (medido con los valores por defecto, 24 dientes).
     "cilindros_calado" cilindros_90 con el tope del acople en V invertida (o media cana,
                    forma_tope) a la distancia d_tope del eje Hirth: el palo de la otra mitad
                    pasa hasta theta_min = 2*atan(w/d) (ver hirth_calado_corte). d_tope = 0
                    lo calcula desde angulo_min (45 por defecto).
     "cilindros_inv" cilindros_90 invertido: los dientes en la cara plana externa y el palo
                    colgando del otro lado; cada palo queda de su lado del plano de union,
                    giro libre en 360.
     "plano"        la ex hirth_plano.scad: igual que cilindros_inv con un disco fino (12 mm),
                    para armar familias de radios y dientes.
   En "plano" y "cilindros_inv", asiento = "eje" (tuerca/cabeza a la altura del eje del palo,
   canal desde abajo) o "pasante" (base plana, tornillo atraviesa toda la pieza).
   EJES DE LOS PALOS (z = 0 es el plano medio de los dientes = plano de union; B es A volteada,
   asi que un eje en z_c queda a 2*|z_c| del de la otra mitad):
     "tope"                        z_c = 0 (alinear_ejes = true, defecto; el tope crece a
                                   max(alto_tope, g/2)). Con false: z_c = -alto_tope + g/2.
     "cilindros", "_90", "_calado" z_c = -base + g/2 = 0 con la base automatica: coplanares.
     "cilindros_inv", "plano"      z_c = -a - g/2 (desfase 2a + g, giro libre en 360).
                                   Con alinear_ejes = true: z_c = 0, asiento pasante y libres
                                   desde ~90 grados (niega los dientes como cilindros_90).
   Tornillo central de 1/4" PASANTE en todos: avellanado en A, tuerca en B.
   Dos tornillos de presion por palo, paralelos al central (eje Z): uno por la base y otro por arriba.
   ============================================================ */

// Baqueta / eje
include <config.scad>

// Tornillo central y de presion
_medida_central  = 0.25;        // tornillo central de la Hirth (1/4")

// Dientes
_radio           = 30;     // radio del bloque de dientes
// _n_dientes (crestas por vuelta, paso = 360/n) esta en config.scad
_prof_diente     = 8;      // altura de meseta a meseta (cresta +/-prof/2 respecto del tope)
_pendiente       = 2.2;    // >1: flancos mas inclinados, mesetas mas anchas hacia afuera
_luz_radial      = 0.3;    // luz entre el bloque de dientes y la pared del tope

// Tope y acople de baqueta
_pared           = 8;      // espesor de la pared (tope) alrededor de los dientes
_alto_tope       = 20;     // altura del tope; el cilindro de la baqueta apoya en su base
_largo           = 85;     // desde el eje Hirth hasta la boca
_prof_hueco      = 45;     // profundidad del hueco de la baqueta

// Modos cilindros
_largo_extra     = 55;     // la boca de la baqueta queda a radio + largo_extra
_base            = 0;      // 0 = automatico: radio del acople (g/2)
_base_plano      = 12;     // modo plano: espesor del disco bajo los dientes

/* ============================================================
   DISENO (marco "tope abajo")
     z = -alto_tope : base plana del tope y del cilindro de baqueta
     z = 0          : borde superior de la pared del tope (plano de union)
     dientes        : mesetas planas, cresta a +prof/2 y valle a -prof/2
   Los dientes quedan en el centro, hundidos dentro de la pared;
   el espacio que queda encima lo ocupa la otra mitad. El cilindro de
   la baqueta tiene su base alineada con la del tope, se mezcla con el
   tope por hull y sube por encima del plano de union, asi que
   la otra mitad queda con una muesca semicircular donde lo cruza.
   ============================================================ */

// Dientes: fan desde el apice hacia un anillo 2n alternando cresta/valle.
// La pendiente converge en el centro (encastre en todo el radio); las
// mesetas salen de recortar la cresta en +a y el valle en -a (el valle
// recortado es el piso del bolsillo del tope).
module hirth_cara(radio, n, prof_diente, pendiente) {
    a = prof_diente / 2;
    ac = a * pendiente;
    m = 2 * n;
    base = -(ac + 1);
    top = [for (i = [0 : m - 1])
        [radio * cos(i * 180 / n), radio * sin(i * 180 / n), (i % 2 == 0) ? ac : -ac]];
    bot = [for (i = [0 : m - 1])
        [radio * cos(i * 180 / n), radio * sin(i * 180 / n), base]];
    intersection() {
        polyhedron(
            points = concat(top, bot, [[0, 0, 0], [0, 0, base]]),
            faces  = concat(
                [for (i = [0 : m - 1]) [2 * m, (i + 1) % m, i]],
                [for (i = [0 : m - 1]) [i, (i + 1) % m, m + (i + 1) % m, m + i]],
                [for (i = [0 : m - 1]) [2 * m + 1, m + i, m + (i + 1) % m]]
            )
        );
        translate([-radio - 1, -radio - 1, -50]) cube([2 * radio + 2, 2 * radio + 2, 50 + a]);
    }
}

// Posicion Z del eje de la baqueta.
//   alinear = true : eje en z = 0 (plano medio de los dientes = plano de union). Como B es la
//                    misma mitad volteada, sus ejes quedan en el MISMO plano (desfase 0).
//   alinear = false: la base del cilindro queda alineada con la del tope; los ejes de A y B
//                    quedan desfasados 2*(alto_tope - g/2).
// Alto efectivo del tope: con alinear, la base del cilindro baja a -g/2, asi que el tope
// tiene que medir al menos g/2 para que la base siga plana.
function hirth_alto(alto_tope, g, alinear) = alinear ? max(alto_tope, g / 2) : alto_tope;
function hirth_zc(alto_tope, g, alinear = true) = alinear ? 0 : -alto_tope + g / 2;

/* ============================================================
   FORMA DE LA BAQUETA (cilindro + mezcla con el tope, sin hueco)
   inflar > 0 se usa para recortar la otra mitad con luz.
   ============================================================ */
module hirth_forma_baqueta(
    radio, pared, alto_tope, largo, luz_radial, prof_diente,
    inflar          = 0,
    alinear_ejes    = true,
    diametro        = _diametro,
    holgura         = _holgura,
    poly_n          = _poly_n,
    familia_tuerca  = _familia_tuerca,
    subtipo_tuerca  = _subtipo_tuerca,
    medida_tornillo = _medida_tornillo
) {
    g     = grosor_baqueta(diametro, holgura, familia_tuerca, subtipo_tuerca, medida_tornillo);
    alto  = hirth_alto(alto_tope, g, alinear_ejes);
    zc    = hirth_zc(alto, g, alinear_ejes);
    x_in  = radio + luz_radial + 2;
    r_out = radio + pared;
    a     = prof_diente / 2;

    module envolvente() {
        hull() {
            translate([0, 0, -alto]) cylinder(r = r_out, h = 6, $fn = 64);
            translate([x_in, 0, zc])
                acople_cuerpo(
                    largo = largo - x_in, diametro = diametro, holgura = holgura,
                    poly_n = poly_n, familia_tuerca = familia_tuerca,
                    subtipo_tuerca = subtipo_tuerca, medida_tornillo = medida_tornillo
                );
        }
    }
    difference() {
        if (inflar > 0)
            minkowski() { envolvente(); sphere(r = inflar, $fn = 8); }
        else
            envolvente();
        // libre el bolsillo de dientes
        translate([0, 0, -a - 0.01]) cylinder(r = radio + luz_radial - (inflar > 0 ? 0.2 : 0), h = 100, $fn = 64);
    }
}

/* ============================================================
   MITAD
   con_tuerca = false -> lleva la cabeza del tornillo (avellanado)
   con_tuerca = true  -> lleva el bolsillo de la tuerca
   fase: giro de los dientes; la mitad B usa medio paso para que
         las dos baquetas queden alineadas a 0 pasos.
   recorte: hijo opcional (lo que se resta, ya en el marco de esta mitad)
   ============================================================ */
module hirth_mitad(
    con_tuerca         = false,
    fase               = 0,
    radio              = _radio,
    n_dientes          = _n_dientes,
    prof_diente        = _prof_diente,
    pendiente          = _pendiente,
    luz_radial         = _luz_radial,
    pared              = _pared,
    alto_tope          = _alto_tope,
    largo              = _largo,
    profundidad_hueco  = _prof_hueco,
    cantidad_tornillos = 2,       // con 180: uno por la base y otro por arriba, ambos paralelos al central
    angulo_tornillo    = 180,     // paralelo al tornillo central, entra por la base (0 = por arriba, 90 = de costado)
    profundidad_pieza  = 20,
    diametro           = _diametro,
    holgura            = _holgura,
    poly_n             = _poly_n,
    familia_tuerca     = _familia_tuerca,
    subtipo_tuerca     = _subtipo_tuerca,
    medida_tornillo    = _medida_tornillo,
    medida_central     = _medida_central,
    alinear_ejes       = true     // eje del palo en z = 0 (ver hirth_zc)
) {
    g     = grosor_baqueta(diametro, holgura, familia_tuerca, subtipo_tuerca, medida_tornillo);
    alto  = hirth_alto(alto_tope, g, alinear_ejes);
    zc    = hirth_zc(alto, g, alinear_ejes);
    x_in  = radio + luz_radial + 2;
    r_out = radio + pared;
    a     = prof_diente / 2;
    d_central = diametro_tornillo_mm(familia_tuerca, medida_central) + 0.5;
    prof_av   = profundidad_avellano_tuerca(familia_tuerca, medida_central);

    difference() {
        union() {
            // tope con bolsillo hasta el piso de los valles
            difference() {
                translate([0, 0, -alto]) cylinder(r = r_out, h = alto, $fn = 64);
                translate([0, 0, -a]) cylinder(r = radio + luz_radial, h = a + 1, $fn = 64);
            }
            // dientes con meseta
            rotate([0, 0, fase]) hirth_cara(radio, n_dientes, prof_diente, pendiente);
            // cilindro de baqueta mezclado con el tope
            hirth_forma_baqueta(
                radio, pared, alto_tope, largo, luz_radial, prof_diente,
                alinear_ejes = alinear_ejes,
                diametro = diametro, holgura = holgura, poly_n = poly_n,
                familia_tuerca = familia_tuerca, subtipo_tuerca = subtipo_tuerca,
                medida_tornillo = medida_tornillo
            );
        }

        // baqueta + tornillo de presion
        translate([x_in, 0, zc])
            acople_hueco(
                largo = largo - x_in, profundidad_hueco = profundidad_hueco,
                cantidad_tornillos = cantidad_tornillos, angulo_tornillo = angulo_tornillo,
                profundidad_pieza = profundidad_pieza,
                diametro = diametro, holgura = holgura, poly_n = poly_n,
                familia_tuerca = familia_tuerca, subtipo_tuerca = subtipo_tuerca,
                medida_tornillo = medida_tornillo
            );

        // tornillo central
        translate([0, 0, -alto - 1])
            cylinder(d = d_central, h = alto + a + 2, $fn = 24);
        if (con_tuerca)
            translate([0, 0, -alto])
                agujero_tuerca(familia_tuerca, subtipo_tuerca, medida_central, alto + a, 0);
        else
            translate([0, 0, -alto - 0.5])
                avellanado_tuerca(familia_tuerca, medida_central, prof_av + 0.5);

        children();
    }
}

/* ============================================================
   JUNTA HIRTH
   pasos: giro de la mitad B respecto de A, en pasos de 360/n_dientes
          (0 = baquetas alineadas y superpuestas, n/2 = en linea opuestas)
   vista: "ensamblada" | "explosionada" | "impresion" | "A" | "B" | "choque"
   alinear_ejes: true (defecto) pone el eje de cada palo en z = 0, asi los ejes de A y B
          quedan en el mismo plano; el tope crece a max(alto_tope, g/2).
   Cada mitad sale con la muesca que le deja el cilindro de la otra
   (con la luz_radial), en la posicion de "pasos".
   ============================================================ */
module junta_hirth_tope(
    pasos              = 6,
    vista              = "ensamblada",
    holgura_axial      = 0.2,
    separacion         = 60,      // en "explosionada"
    radio              = _radio,
    n_dientes          = _n_dientes,
    prof_diente        = _prof_diente,
    pendiente          = _pendiente,
    luz_radial         = _luz_radial,
    pared              = _pared,
    alto_tope          = _alto_tope,
    largo              = _largo,
    profundidad_hueco  = _prof_hueco,
    cantidad_tornillos = 2,       // con 180: uno por la base y otro por arriba, ambos paralelos al central
    angulo_tornillo    = 180,     // paralelo al tornillo central, entra por la base (0 = por arriba, 90 = de costado)
    profundidad_pieza  = 20,
    diametro           = _diametro,
    holgura            = _holgura,
    poly_n             = _poly_n,
    familia_tuerca     = _familia_tuerca,
    subtipo_tuerca     = _subtipo_tuerca,
    medida_tornillo    = _medida_tornillo,
    medida_central     = _medida_central,
    alinear_ejes       = true     // ejes de A y B en el mismo plano (z = 0)
) {
    paso = 360 / n_dientes;
    ang  = pasos * paso;
    g    = grosor_baqueta(diametro, holgura, familia_tuerca, subtipo_tuerca, medida_tornillo);
    alto = hirth_alto(alto_tope, g, alinear_ejes);
    zc   = hirth_zc(alto, g, alinear_ejes);

    echo(str("Hirth: paso=", paso, " grados, giro=", ang,
             " grados, alto del tope=", alto, " mm, eje del palo en z=", zc,
             " (desfase entre ejes A-B ", 2 * abs(zc), " mm), largo minimo del tornillo central ~ ",
             2 * alto + holgura_axial, " mm + cabeza/tuerca"));

    module mitad(con_tuerca, fase)
        hirth_mitad(
            con_tuerca = con_tuerca, fase = fase,
            radio = radio, n_dientes = n_dientes, prof_diente = prof_diente,
            pendiente = pendiente, luz_radial = luz_radial, pared = pared,
            alto_tope = alto_tope, largo = largo, profundidad_hueco = profundidad_hueco,
            cantidad_tornillos = cantidad_tornillos, angulo_tornillo = angulo_tornillo,
            profundidad_pieza = profundidad_pieza,
            diametro = diametro, holgura = holgura, poly_n = poly_n,
            familia_tuerca = familia_tuerca, subtipo_tuerca = subtipo_tuerca,
            medida_tornillo = medida_tornillo, medida_central = medida_central,
            alinear_ejes = alinear_ejes
        ) children();

    module forma()
        hirth_forma_baqueta(
            radio, pared, alto_tope, largo, luz_radial, prof_diente,
            inflar = luz_radial, alinear_ejes = alinear_ejes,
            diametro = diametro, holgura = holgura, poly_n = poly_n,
            familia_tuerca = familia_tuerca, subtipo_tuerca = subtipo_tuerca,
            medida_tornillo = medida_tornillo
        );

    // transformacion de B al marco de A (volteada, girada, con luz axial)
    module a_marco_de_A(extra = 0)
        translate([0, 0, holgura_axial + extra])
            rotate([0, 0, ang]) rotate([180, 0, 0]) children();
    // la inversa: lleva algo del marco de A al marco propio de B
    module a_marco_de_B()
        rotate([180, 0, 0]) rotate([0, 0, -ang])
            translate([0, 0, -holgura_axial]) children();

    module mitad_A() mitad(false, 0) a_marco_de_A() forma();
    module mitad_B() mitad(true, paso / 2) a_marco_de_B() forma();

    if (vista == "A")
        mitad_A();
    else if (vista == "B")
        mitad_B();
    else if (vista == "impresion") {
        mitad_A();
        translate([0, -2.2 * (radio + pared) - 20, 0]) mitad_B();
    } else if (vista == "choque")
        intersection() { mitad_A(); a_marco_de_A() mitad_B(); }
    else {
        mitad_A();
        a_marco_de_A(vista == "explosionada" ? separacion : 0)
            mitad_B();
    }
}



/* ============================================================
   TORNILLO CENTRAL (comun a cilindros, plano e invertida)
   Se resta DESPUES del hull, asi la tuerca y la cabeza no quedan
   tapadas por la mezcla disco-palo.
     z_fondo  : cara mas baja de la pieza (de ahi sale el canal)
     z_asiento: donde apoya la tuerca o la cabeza
     z_tope   : hasta donde sube el agujero (los dientes)
   Si z_asiento > z_fondo se abre un canal desde abajo hasta el asiento:
   hexagonal para la tuerca (entra por abajo y no gira) y redondo para
   la cabeza (y la llave).
   ============================================================ */
module hirth_tornillo_central(
    con_tuerca,
    z_asiento,
    z_fondo,
    z_tope,
    familia_tuerca = _familia_tuerca,
    subtipo_tuerca = _subtipo_tuerca,
    medida_central = _medida_central
) {
    d_central = diametro_tornillo_mm(familia_tuerca, medida_central) + 0.5;
    prof_av   = profundidad_avellano_tuerca(familia_tuerca, medida_central);
    esp       = datos_tuerca(familia_tuerca, subtipo_tuerca, medida_central)[1];
    canal     = z_asiento > z_fondo;

    translate([0, 0, z_fondo - 1]) cylinder(d = d_central, h = z_tope - z_fondo + 1, $fn = 24);
    if (con_tuerca) {
        translate([0, 0, z_asiento])
            agujero_tuerca(familia_tuerca, subtipo_tuerca, medida_central, z_tope - z_asiento, 0);
        if (canal)
            hull() for (z = [z_fondo - 1, z_asiento]) translate([0, 0, z])
                agujero_tuerca(familia_tuerca, subtipo_tuerca, medida_central, esp, 0);
    } else {
        translate([0, 0, z_asiento - 0.5])
            avellanado_tuerca(familia_tuerca, medida_central, prof_av + 0.5);
        if (canal)
            hull() for (z = [z_fondo - 1, z_asiento - 0.5]) translate([0, 0, z])
                avellanado_tuerca(familia_tuerca, medida_central, prof_av + 0.5);
    }
}

/* ============================================================
   MODO "cilindros_calado": CUENTA DEL TOPE
   w = medio ancho del acople (radio del palo + armadura, g/2) + luz_tope
   d = distancia del eje vertical Hirth al plano donde arranca el tope
   Dos franjas de medio ancho w que arrancan a distancia d del eje y
   forman un angulo theta dejan de chocar cuando d >= w * cot(theta/2):
       theta_min = 2 * atan(w / d)          (exacta)
       theta_min ~ 2 * w / d  [radianes]    (angulos chicos: el arco
                                             theta*d cubre el ancho 2w)
   Al reves, para un angulo pedido: d = w / tan(angulo_min / 2).
   En planta el material de arriba del plano de union tiene que cumplir
       x >= (w + |y| * cos(theta)) / sin(theta)
   que es una V invertida: punta en x = w / sin(theta) (hacia el eje) y
   cantos en (d, +-w).
   ============================================================ */
function hirth_calado_w(luz_tope, diametro = _diametro, holgura = _holgura,
                        familia_tuerca = _familia_tuerca, subtipo_tuerca = _subtipo_tuerca,
                        medida_tornillo = _medida_tornillo) =
    grosor_baqueta(diametro, holgura, familia_tuerca, subtipo_tuerca, medida_tornillo) / 2 + luz_tope;
function hirth_calado_d(d_tope, angulo_min, w) = d_tope > 0 ? d_tope : w / tan(angulo_min / 2);
function hirth_calado_theta(w, d) = 2 * atan(w / d);   // grados

// Lo que se saca por encima del plano de union (en planta, se extruye en Z)
module hirth_calado_corte(w, d, forma_tope = "v", grande = 500) {
    theta  = hirth_calado_theta(w, d);
    x_nariz = w / sin(theta);
    module v()
        polygon([[-grande, -grande], [d, -grande], [d, -w], [x_nariz, 0],
                 [d, w], [d, grande], [-grande, grande]]);
    if (forma_tope == "media_cana")
        // cierre: redondea la punta tangente a la V (saca mas material, igual de seguro)
        offset(r = -w) offset(r = w) v();
    else
        v();
}

/* ============================================================
   MODOS "cilindros", "cilindros_90" y "cilindros_calado"
   ============================================================ */
module hirth_cil_mitad(
    con_tuerca         = false,
    fase               = 0,
    radio              = _radio,
    n_dientes          = _n_dientes,
    prof_diente        = _prof_diente,
    pendiente          = _pendiente,
    base_              = _base,
    largo_extra        = _largo_extra,
    x_palo             = 12,      // donde arranca el cuerpo del palo
    r_corte            = 0,       // radio del cilindro que niega el espacio sobre el disco (0 = radio de los dientes)
    calado             = false,   // true: tope en V invertida (modo "cilindros_calado")
    d_tope             = 0,       // distancia eje Hirth -> plano del tope (0 = sale de angulo_min)
    angulo_min         = 45,      // angulo minimo buscado cuando d_tope = 0
    forma_tope         = "v",     // "v" | "media_cana"
    luz_tope           = 1,       // luz que se suma al medio ancho del acople
    profundidad_hueco  = _prof_hueco,
    cantidad_tornillos = 2,       // con 180: uno por la base y otro por arriba, ambos paralelos al central
    angulo_tornillo    = 180,     // paralelo al tornillo central, entra por la base (0 = por arriba, 90 = de costado)
    profundidad_pieza  = 20,
    diametro           = _diametro,
    holgura            = _holgura,
    poly_n             = _poly_n,
    familia_tuerca     = _familia_tuerca,
    subtipo_tuerca     = _subtipo_tuerca,
    medida_tornillo    = _medida_tornillo,
    medida_central     = _medida_central
) {
    a     = prof_diente / 2;
    g     = grosor_baqueta(diametro, holgura, familia_tuerca, subtipo_tuerca, medida_tornillo);
    base  = base_ > 0 ? base_ : g / 2;     // alto del cilindro = radio del acople
    x_in  = x_palo;
    zc    = -base + g / 2;   // eje del palo (= 0 con la base automatica: a la altura de los dientes)
    w     = hirth_calado_w(luz_tope, diametro, holgura, familia_tuerca, subtipo_tuerca, medida_tornillo);
    d     = hirth_calado_d(d_tope, angulo_min, w);
    // en el calado el hueco del palo arranca despues del tope, para que el corte no lo abra
    largo = calado ? max(radio + largo_extra, d + profundidad_hueco) : radio + largo_extra;
    if (calado) assert(d > radio, str("hirth calado: d_tope (", d, ") tiene que ser mayor que el radio (", radio, ")"));

    module palo(l)
        translate([x_in, 0, zc])
            acople_cuerpo(
                largo = l - x_in, diametro = diametro, holgura = holgura,
                poly_n = poly_n, familia_tuerca = familia_tuerca,
                subtipo_tuerca = subtipo_tuerca, medida_tornillo = medida_tornillo
            );

    difference() {
        union() {
            // 1-2: hull cilindro + palo, menos el espacio de los dientes
            difference() {
                union() {
                    hull() {
                        translate([0, 0, -base]) cylinder(r = radio, h = base - a, $fn = 96);
                        // calado: el hull llega solo hasta el tope, despues sigue el palo solo
                        palo(calado ? d : largo);
                    }
                    if (calado) palo(largo);
                }
                translate([0, 0, -a]) cylinder(r = max(radio, r_corte) + 0.02, h = 3 * g, $fn = 96);
                if (calado)
                    translate([0, 0, -a]) linear_extrude(height = 3 * g)
                        hirth_calado_corte(w, d, forma_tope);
            }
            // 3: union de los dientes
            rotate([0, 0, fase]) hirth_cara(radio, n_dientes, prof_diente, pendiente);
        }
        // hueco del palo + tornillo de presion
        translate([x_in, 0, zc])
            acople_hueco(
                largo = largo - x_in, profundidad_hueco = profundidad_hueco,
                cantidad_tornillos = cantidad_tornillos, angulo_tornillo = angulo_tornillo,
                profundidad_pieza = profundidad_pieza,
                diametro = diametro, holgura = holgura, poly_n = poly_n,
                familia_tuerca = familia_tuerca, subtipo_tuerca = subtipo_tuerca,
                medida_tornillo = medida_tornillo
            );
        // tornillo central 1/4": cabeza avellanada en una mitad, tuerca en la otra
        hirth_tornillo_central(con_tuerca, -base, -base, a + 1,
                               familia_tuerca, subtipo_tuerca, medida_central);
    }
}

/* vista: "ensamblada" | "explosionada" | "impresion" | "A" | "B" | "choque"
   pasos: giro de B respecto de A en pasos de 360/n_dientes
   "choque": interseccion de A y B ensambladas; vacia = sin interferencia */
module junta_hirth_cil(
    pasos         = 6,
    vista         = "ensamblada",
    holgura_axial = 0.2,
    separacion    = 50,
    radio         = _radio,
    n_dientes     = _n_dientes,
    prof_diente   = _prof_diente,
    x_palo        = 12,
    r_corte       = 0,
    calado        = false,
    d_tope        = 0,
    angulo_min    = 45,
    forma_tope    = "v",
    luz_tope      = 1
) {
    paso = 360 / n_dientes;
    if (calado) {
        w     = hirth_calado_w(luz_tope);
        d     = hirth_calado_d(d_tope, angulo_min, w);
        theta = hirth_calado_theta(w, d);
        k_min = ceil(theta / paso - 1e-6);   // 1e-6: que 45.0000001 no salte un paso
        echo(str("Hirth calado R=", radio, " n=", n_dientes, ": d_tope=", d, " mm, w=", w,
                 " mm -> theta_min = 2*atan(w/d) = ", theta * PI / 180, " rad (", theta,
                 " grados; aprox 2w/d = ", 2 * w / d, " rad). Pasos libres de ", k_min,
                 " a ", n_dientes - k_min, " (desde ", k_min * paso, " grados)"));
    } else
        echo(str("Hirth cilindros R=", radio, " n=", n_dientes, ": paso ", paso, " grados; palos libres desde ",
                 r_corte > radio ? "90" : "150", " grados"));

    module mitad(con_tuerca, fase)
        hirth_cil_mitad(con_tuerca = con_tuerca, fase = fase, radio = radio,
                        n_dientes = n_dientes, prof_diente = prof_diente, x_palo = x_palo, r_corte = r_corte,
                        calado = calado, d_tope = d_tope, angulo_min = angulo_min,
                        forma_tope = forma_tope, luz_tope = luz_tope);

    module b_ensamblada(extra = 0)
        translate([0, 0, holgura_axial + extra])
            rotate([0, 0, pasos * paso]) rotate([180, 0, 0])
                mitad(true, paso / 2);

    if (vista == "A")
        mitad(false, 0);
    else if (vista == "B")
        mitad(true, paso / 2);
    else if (vista == "impresion") {
        mitad(false, 0);
        translate([0, -2.2 * radio - 40, 0]) mitad(true, paso / 2);
    } else if (vista == "choque")
        intersection() { mitad(false, 0); b_ensamblada(); }
    else {
        mitad(false, 0);
        b_ensamblada(vista == "explosionada" ? separacion : 0);
    }
}

/* ============================================================
   MODOS "plano" y "cilindros_inv"
   Cada mitad es un disco con la cara de dientes (con meseta) arriba,
   en la cara plana, y el palo cuelga debajo con su borde superior al
   ras del piso de los valles. Cada palo queda de su lado del plano de
   union: no hay interferencia a ningun angulo (giro libre en 360).
     "plano"         disco de base fija (12 mm), 1 tornillo de presion de costado.
     "cilindros_inv" cilindros_90 invertido: alto del cilindro = radio del acople
                     (base = g/2), mismos tornillos de presion que cilindros.
   Marco de cada mitad: dientes arriba, plano de union en Z = 0, palo a
   lo largo de +X. La mitad B se da vuelta (rotate 180 en X).
   asiento: "eje"     la tuerca o la cabeza apoyan a la altura del eje del palo,
                      con un canal desde abajo (tornillo corto).
            "pasante" se suma al hull un disco bajo el eje Hirth: la base queda
                      plana y la tuerca o la cabeza apoyan abajo de todo (tornillo largo).
   ============================================================ */
module hirth_plano_mitad(
    con_tuerca         = false,
    fase               = 0,
    radio              = _radio,
    n_dientes          = _n_dientes,
    prof_diente        = _prof_diente,
    pendiente          = _pendiente,
    base               = _base_plano,   // 0 = automatico: radio del acople (g/2)
    largo_extra        = _largo_extra,
    x_palo             = 12,
    asiento            = "eje",
    alinear_ejes       = false,   // true: eje del palo en z = 0 (ejes de A y B coplanares)
    r_corte            = 0,       // con alinear_ejes: radio que niega el espacio sobre el disco (0 = radio + 10)
    profundidad_hueco  = _prof_hueco,
    cantidad_tornillos = 1,
    angulo_tornillo    = 90,
    profundidad_pieza  = 20,
    diametro           = _diametro,
    holgura            = _holgura,
    poly_n             = _poly_n,
    familia_tuerca     = _familia_tuerca,
    subtipo_tuerca     = _subtipo_tuerca,
    medida_tornillo    = _medida_tornillo,
    medida_central     = _medida_central
) {
    a      = prof_diente / 2;
    g      = grosor_baqueta(diametro, holgura, familia_tuerca, subtipo_tuerca, medida_tornillo);
    base_  = base > 0 ? base : g / 2;
    largo  = radio + largo_extra;
    x_in   = x_palo;
    // sin alinear el cilindro cuelga justo bajo el piso de los valles (desfase A-B = 2a + g);
    // alineado sube a z = 0 y cruza el plano de union (se pierde el giro libre en 360)
    zc     = alinear_ejes ? 0 : -a - g / 2;
    z_fondo = alinear_ejes ? -max(base_, g / 2) : zc - g / 2;
    r_neg  = r_corte > 0 ? r_corte : radio + 10;
    r_pie  = ancho_tuerca(familia_tuerca, subtipo_tuerca, medida_central) / 2 / cos(30) + 4;
    // alineado: con "eje" el canal llegaria hasta los dientes, se fuerza "pasante"
    z_asiento = (asiento == "pasante" || alinear_ejes) ? z_fondo : zc;

    difference() {
        union() {
            rotate([0, 0, fase]) hirth_cara(radio, n_dientes, prof_diente, pendiente);
            // disco + palo mezclados ANTES de restar los tornillos
            difference() {
                hull() {
                    translate([0, 0, -base_]) cylinder(r = radio, h = base_ - a + 0.01, $fn = 64);
                    translate([x_in, 0, zc])
                        acople_cuerpo(
                            largo = largo - x_in, diametro = diametro, holgura = holgura,
                            poly_n = poly_n, familia_tuerca = familia_tuerca,
                            subtipo_tuerca = subtipo_tuerca, medida_tornillo = medida_tornillo
                        );
                    // pasante: pie plano bajo el eje Hirth para que apoye la tuerca o la cabeza
                    if (asiento == "pasante" || alinear_ejes)
                        translate([0, 0, z_fondo]) cylinder(r = r_pie, h = 1, $fn = 48);
                }
                // alineado: niega el espacio de los dientes sobre el palo (como cilindros_90)
                if (alinear_ejes)
                    translate([0, 0, -a]) cylinder(r = max(radio, r_neg) + 0.02, h = 3 * g, $fn = 96);
            }
        }
        translate([x_in, 0, zc])
            acople_hueco(
                largo = largo - x_in, profundidad_hueco = profundidad_hueco,
                cantidad_tornillos = cantidad_tornillos, angulo_tornillo = angulo_tornillo,
                profundidad_pieza = profundidad_pieza,
                diametro = diametro, holgura = holgura, poly_n = poly_n,
                familia_tuerca = familia_tuerca, subtipo_tuerca = subtipo_tuerca,
                medida_tornillo = medida_tornillo
            );
        // tornillo central 1/4": cabeza avellanada en una mitad, tuerca en la otra
        hirth_tornillo_central(con_tuerca, z_asiento, z_fondo, a + 1,
                               familia_tuerca, subtipo_tuerca, medida_central);
    }
}

/* vista: "ensamblada" | "explosionada" | "impresion" | "A" | "B" | "choque"
   pasos: giro de B respecto de A en pasos de 360/n_dientes */
module junta_hirth_plana(
    pasos              = 6,
    vista              = "ensamblada",
    holgura_axial      = 0.2,
    separacion         = 50,
    radio              = _radio,
    n_dientes          = _n_dientes,
    prof_diente        = _prof_diente,
    pendiente          = _pendiente,
    base               = _base_plano,
    largo_extra        = _largo_extra,
    x_palo             = 12,
    asiento            = "eje",
    alinear_ejes       = false,
    r_corte            = 0,
    profundidad_hueco  = _prof_hueco,
    cantidad_tornillos = 1,
    angulo_tornillo    = 90,
    profundidad_pieza  = 20,
    diametro           = _diametro,
    holgura            = _holgura,
    poly_n             = _poly_n,
    familia_tuerca     = _familia_tuerca,
    subtipo_tuerca     = _subtipo_tuerca,
    medida_tornillo    = _medida_tornillo,
    medida_central     = _medida_central
) {
    paso = 360 / n_dientes;
    g    = grosor_baqueta(diametro, holgura, familia_tuerca, subtipo_tuerca, medida_tornillo);
    zc   = alinear_ejes ? 0 : -prof_diente / 2 - g / 2;
    z_asiento = alinear_ejes ? -max(base > 0 ? base : g / 2, g / 2)
              : asiento == "pasante" ? zc - g / 2 : zc;

    if (alinear_ejes)
        echo(str("Hirth plana R=", radio, " n=", n_dientes, ": paso ", paso,
                 " grados, ejes alineados (z=0, desfase 0); palos libres desde ~90 grados",
                 " (verificar con vista = \"choque\"); asiento pasante: entre asientos ",
                 -2 * z_asiento + holgura_axial, " mm (+ cabeza/tuerca)"));
    else
        echo(str("Hirth plana R=", radio, " n=", n_dientes, ": paso ", paso, " grados, giro libre 360",
                 ", desfase entre ejes A-B ", 2 * abs(zc), " mm; asiento '",
                 asiento, "': entre asientos ", -2 * z_asiento + holgura_axial, " mm (+ cabeza/tuerca)"));

    module mitad(con_tuerca, fase)
        hirth_plano_mitad(
            con_tuerca = con_tuerca, fase = fase,
            radio = radio, n_dientes = n_dientes, prof_diente = prof_diente,
            pendiente = pendiente, base = base, largo_extra = largo_extra,
            x_palo = x_palo, asiento = asiento,
            alinear_ejes = alinear_ejes, r_corte = r_corte,
            profundidad_hueco = profundidad_hueco,
            cantidad_tornillos = cantidad_tornillos, angulo_tornillo = angulo_tornillo,
            profundidad_pieza = profundidad_pieza,
            diametro = diametro, holgura = holgura, poly_n = poly_n,
            familia_tuerca = familia_tuerca, subtipo_tuerca = subtipo_tuerca,
            medida_tornillo = medida_tornillo, medida_central = medida_central
        );

    module b_ensamblada(extra = 0)
        translate([0, 0, holgura_axial + extra])
            rotate([0, 0, pasos * paso]) rotate([180, 0, 0])
                mitad(true, paso / 2);

    if (vista == "A")
        mitad(false, 0);
    else if (vista == "B")
        mitad(true, paso / 2);
    else if (vista == "impresion") {
        mitad(false, 0);
        translate([0, -2.2 * radio - 40, 0]) mitad(true, paso / 2);
    } else if (vista == "choque")
        intersection() { mitad(false, 0); b_ensamblada(); }
    else {
        mitad(false, 0);
        b_ensamblada(vista == "explosionada" ? separacion : 0);
    }
}

/* ============================================================
   JUNTA HIRTH (punto de entrada de los seis modos)
   modo: "tope" | "cilindros" | "cilindros_90" | "cilindros_calado"
         | "cilindros_inv" | "plano"                (ver cabecera)
   vista: "ensamblada" | "explosionada" | "impresion" | "A" | "B"
          (+ "choque": interseccion A-B ensambladas, vacia = sin interferencia)
   pasos: giro de B respecto de A en pasos de 360/n_dientes
   asiento: "eje" | "pasante"       (solo "plano" y "cilindros_inv")
   alinear_ejes: ejes de A y B en el mismo plano (z = 0). En "tope" vale true por defecto;
          los cilindros ya lo estan; en "plano" y "cilindros_inv" es opcional (fuerza asiento
          pasante y se pierde el giro libre en 360: libres desde ~90 grados como cilindros_90).
   d_tope, angulo_min, forma_tope   (solo "cilindros_calado")
   Para ajustar a fondo el modo "tope" (pared, alto, tornillos) usar junta_hirth_tope().
   ============================================================ */
module junta_hirth(
    modo          = "tope",
    pasos         = 6,
    vista         = "ensamblada",
    holgura_axial = 0.2,
    separacion    = 50,
    radio         = _radio,
    n_dientes     = _n_dientes,
    prof_diente   = _prof_diente,
    asiento       = "eje",
    d_tope        = 0,
    angulo_min    = 45,
    forma_tope    = "v",
    alinear_ejes  = undef   // undef: true en "tope", false en "plano" y "cilindros_inv"
) {
    if (modo == "tope")
        junta_hirth_tope(pasos = pasos, vista = vista, holgura_axial = holgura_axial,
                         separacion = separacion, radio = radio, n_dientes = n_dientes,
                         prof_diente = prof_diente,
                         alinear_ejes = is_undef(alinear_ejes) ? true : alinear_ejes);
    else if (modo == "cilindros")
        junta_hirth_cil(pasos = pasos, vista = vista, holgura_axial = holgura_axial,
                        separacion = separacion, radio = radio, n_dientes = n_dientes,
                        prof_diente = prof_diente);
    else if (modo == "cilindros_90")
        junta_hirth_cil(pasos = pasos, vista = vista, holgura_axial = holgura_axial,
                        separacion = separacion, radio = radio, n_dientes = n_dientes,
                        prof_diente = prof_diente, r_corte = radio + 10);
    else if (modo == "cilindros_calado")
        junta_hirth_cil(pasos = pasos, vista = vista, holgura_axial = holgura_axial,
                        separacion = separacion, radio = radio, n_dientes = n_dientes,
                        prof_diente = prof_diente, calado = true, d_tope = d_tope,
                        angulo_min = angulo_min, forma_tope = forma_tope);
    else if (modo == "cilindros_inv")
        junta_hirth_plana(pasos = pasos, vista = vista, holgura_axial = holgura_axial,
                          separacion = separacion, radio = radio, n_dientes = n_dientes,
                          prof_diente = prof_diente, base = 0, asiento = asiento,
                          alinear_ejes = is_undef(alinear_ejes) ? false : alinear_ejes,
                          cantidad_tornillos = 2, angulo_tornillo = 180);
    else if (modo == "plano")
        junta_hirth_plana(pasos = pasos, vista = vista, holgura_axial = holgura_axial,
                          separacion = separacion, radio = radio, n_dientes = n_dientes,
                          prof_diente = prof_diente, asiento = asiento,
                          alinear_ejes = is_undef(alinear_ejes) ? false : alinear_ejes);
    else
        echo(str("junta_hirth: modo desconocido -> '", modo, "'"));
}

/* ============================================================
   DEMO
   ============================================================ */

// modo tope, a 90 grados (6 pasos de 15)
junta_hirth(pasos = 6);

// cilindros (palos libres solo entre 150 y 210 grados)
translate([0, 220, 0]) junta_hirth(modo = "cilindros", pasos = 12);

// cilindros_90 a 90 grados
translate([0, 440, 0]) junta_hirth(modo = "cilindros_90", pasos = 6);

// explosionada para ver los dientes
translate([260, 0, 0]) junta_hirth(modo = "cilindros_90", pasos = 8, vista = "explosionada");

// lista para imprimir (base plana abajo, dientes hacia arriba)
translate([260, 220, 0]) junta_hirth(modo = "cilindros_90", vista = "impresion");

// cilindros_calado: tope en V invertida, a 45 grados (3 pasos de 15, ver el echo)
translate([0, 660, 0]) junta_hirth(modo = "cilindros_calado", pasos = 3);
// la misma con media cana; "choque" tiene que salir vacio
translate([260, 660, 0]) junta_hirth(modo = "cilindros_calado", pasos = 3, forma_tope = "media_cana");
translate([520, 660, 0]) junta_hirth(modo = "cilindros_calado", pasos = 3, vista = "choque");

// cilindros_inv: dientes en la cara plana, palos superpuestos (0 pasos), asiento en el eje y pasante
translate([0, 900, 0]) junta_hirth(modo = "cilindros_inv", pasos = 0);
translate([260, 900, 0]) junta_hirth(modo = "cilindros_inv", pasos = 2, asiento = "pasante");
// cilindros_inv con los ejes alineados en el mismo plano, a 90 grados
translate([520, 900, 0]) junta_hirth(modo = "cilindros_inv", pasos = 6, alinear_ejes = true);

// plano: familia de tamanos (mas radio -> mas dientes; paso sobre el borde de 7 a 10 mm)
translate([0, 1140, 0])
    junta_hirth_plana(radio = 25, n_dientes = 16, prof_diente = 6, pasos = 4);
translate([0, 1320, 0])
    junta_hirth_plana(radio = 30, n_dientes = 24, prof_diente = 8, pasos = 6);
translate([0, 1540, 0])
    junta_hirth_plana(radio = 40, n_dientes = 36, prof_diente = 10, pasos = 9, asiento = "pasante");
