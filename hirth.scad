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
   ============================================================ */

// Baqueta / eje
_diametro        = 24;
_holgura         = 0.5;
_poly_n          = 16;

// Tornillo central y de presion
_familia_tuerca  = "UNC";
_subtipo_tuerca  = "normal";
_medida_tornillo = 0.1875;      // tornillo de presion sobre la baqueta
_medida_central  = 0.25;        // tornillo central de la Hirth (1/4")

// Dientes
_radio           = 30;     // radio del bloque de dientes
_n_dientes       = 24;     // crestas por vuelta -> paso = 360/n
_prof_diente     = 8;      // altura de meseta a meseta (cresta +/-prof/2 respecto del tope)
_pendiente       = 2.2;    // >1: flancos mas inclinados, mesetas mas anchas hacia afuera
_luz_radial      = 0.3;    // luz entre el bloque de dientes y la pared del tope

// Tope y acople de baqueta
_pared           = 8;      // espesor de la pared (tope) alrededor de los dientes
_alto_tope       = 20;     // altura del tope; el cilindro de la baqueta apoya en su base
_largo           = 85;     // desde el eje Hirth hasta la boca
_prof_hueco      = 45;     // profundidad del hueco de la baqueta

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

// Posicion Z del eje de la baqueta: su base queda alineada con la del tope
function hirth_zc(alto_tope, g) = -alto_tope + g / 2;

/* ============================================================
   FORMA DE LA BAQUETA (cilindro + mezcla con el tope, sin hueco)
   inflar > 0 se usa para recortar la otra mitad con luz.
   ============================================================ */
module hirth_forma_baqueta(
    radio, pared, alto_tope, largo, luz_radial, prof_diente,
    inflar          = 0,
    diametro        = _diametro,
    holgura         = _holgura,
    poly_n          = _poly_n,
    familia_tuerca  = _familia_tuerca,
    subtipo_tuerca  = _subtipo_tuerca,
    medida_tornillo = _medida_tornillo
) {
    g     = grosor_baqueta(diametro, holgura, familia_tuerca, subtipo_tuerca, medida_tornillo);
    zc    = hirth_zc(alto_tope, g);
    x_in  = radio + luz_radial + 2;
    r_out = radio + pared;
    a     = prof_diente / 2;

    module envolvente() {
        hull() {
            translate([0, 0, -alto_tope]) cylinder(r = r_out, h = 6, $fn = 64);
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
    g     = grosor_baqueta(diametro, holgura, familia_tuerca, subtipo_tuerca, medida_tornillo);
    zc    = hirth_zc(alto_tope, g);
    x_in  = radio + luz_radial + 2;
    r_out = radio + pared;
    a     = prof_diente / 2;
    d_central = diametro_tornillo_mm(familia_tuerca, medida_central) + 0.5;
    prof_av   = profundidad_avellano_tuerca(familia_tuerca, medida_central);

    difference() {
        union() {
            // tope con bolsillo hasta el piso de los valles
            difference() {
                translate([0, 0, -alto_tope]) cylinder(r = r_out, h = alto_tope, $fn = 64);
                translate([0, 0, -a]) cylinder(r = radio + luz_radial, h = a + 1, $fn = 64);
            }
            // dientes con meseta
            rotate([0, 0, fase]) hirth_cara(radio, n_dientes, prof_diente, pendiente);
            // cilindro de baqueta mezclado con el tope
            hirth_forma_baqueta(
                radio, pared, alto_tope, largo, luz_radial, prof_diente,
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
        translate([0, 0, -alto_tope - 1])
            cylinder(d = d_central, h = alto_tope + a + 2, $fn = 24);
        if (con_tuerca)
            translate([0, 0, -alto_tope])
                agujero_tuerca(familia_tuerca, subtipo_tuerca, medida_central, alto_tope + a, 0);
        else
            translate([0, 0, -alto_tope - 0.5])
                avellanado_tuerca(familia_tuerca, medida_central, prof_av + 0.5);

        children();
    }
}

/* ============================================================
   JUNTA HIRTH
   pasos: giro de la mitad B respecto de A, en pasos de 360/n_dientes
          (0 = baquetas alineadas y superpuestas, n/2 = en linea opuestas)
   vista: "ensamblada" | "explosionada" | "impresion" | "A" | "B"
   Cada mitad sale con la muesca que le deja el cilindro de la otra
   (con la luz_radial), en la posicion de "pasos".
   ============================================================ */
module junta_hirth(
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
    ang  = pasos * paso;

    echo(str("Hirth: paso=", paso, " grados, giro=", ang,
             " grados, largo minimo del tornillo central ~ ",
             2 * alto_tope + holgura_axial, " mm + cabeza/tuerca"));

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
            medida_tornillo = medida_tornillo, medida_central = medida_central
        ) children();

    module forma()
        hirth_forma_baqueta(
            radio, pared, alto_tope, largo, luz_radial, prof_diente,
            inflar = luz_radial,
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
    } else {
        mitad_A();
        a_marco_de_A(vista == "explosionada" ? separacion : 0)
            mitad_B();
    }
}


/* ============================================================
   DEMO
   ============================================================ */

// Ensamblada a 90 grados (6 pasos de 15)
junta_hirth(pasos = 6);

// Explosionada para ver los dientes
translate([0, 220, 0])
    junta_hirth(pasos = 6, vista = "explosionada");

// Lista para imprimir (base plana abajo, dientes hacia arriba)
translate([220, 0, 0])
    junta_hirth(vista = "impresion");
