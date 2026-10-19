use <hueco_baqueta.scad>
use <utils/acople.scad>
use <hirth.scad>

/* ============================================================
   JUNTA HIRTH PLANA (sin encastre de tope)
   Variante simple de hirth.scad: cada mitad es un disco con la cara
   de dientes (con meseta) al ras, sin pared ni bolsillo y sin
   muescas. Las dos baquetas cuelgan de su lado del plano de union,
   asi que no hay interferencia entre mitades a ningun angulo.

   Sirve para armar una familia de juntas con distintos diametros y
   cantidad de dientes: se cambian radio y n_dientes (el paso de giro
   es 360/n_dientes). El tornillo central es de 1/4" con avellanado en
   una mitad y tuerca en la otra.

   Marco de cada mitad: dientes arriba, plano de union en Z = 0,
   base plana en Z = -base, baqueta a lo largo de +X colgando debajo.
   La mitad B se da vuelta (rotate 180 en X) para enfrentarla.
   ============================================================ */

// Baqueta / eje
_diametro        = 24;
_holgura         = 0.5;
_poly_n          = 16;

// Tornillos
_familia_tuerca  = "UNC";
_subtipo_tuerca  = "normal";
_medida_tornillo = 0.1875;      // presion sobre la baqueta
_medida_central  = 0.25;        // tornillo central (1/4")

// Dientes
_radio           = 30;
_n_dientes       = 24;
_prof_diente     = 8;
_pendiente       = 2.2;
_base            = 12;          // espesor del disco bajo el piso de los valles
_largo_extra     = 55;          // la boca de la baqueta queda a radio + largo_extra
_prof_hueco      = 45;

module hirth_plano_mitad(
    con_tuerca         = false,
    fase               = 0,
    radio              = _radio,
    n_dientes          = _n_dientes,
    prof_diente        = _prof_diente,
    pendiente          = _pendiente,
    base               = _base,
    largo_extra        = _largo_extra,
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
    a     = prof_diente / 2;
    g     = grosor_baqueta(diametro, holgura, familia_tuerca, subtipo_tuerca, medida_tornillo);
    largo = radio + largo_extra;
    x_in  = 12;
    zc    = -a - g / 2;      // el cilindro cuelga justo bajo el piso de los valles
    d_central = diametro_tornillo_mm(familia_tuerca, medida_central) + 0.5;
    prof_av   = profundidad_avellano_tuerca(familia_tuerca, medida_central);

    difference() {
        union() {
            translate([0, 0, -base]) cylinder(r = radio, h = base - a + 0.01, $fn = 64);
            rotate([0, 0, fase]) hirth_cara(radio, n_dientes, prof_diente, pendiente);
            // union entre disco y cilindro de baqueta
            hull() {
                translate([0, 0, -base]) cylinder(r = radio, h = 4, $fn = 64);
                translate([x_in, 0, zc])
                    acople_cuerpo(
                        largo = largo - x_in, diametro = diametro, holgura = holgura,
                        poly_n = poly_n, familia_tuerca = familia_tuerca,
                        subtipo_tuerca = subtipo_tuerca, medida_tornillo = medida_tornillo
                    );
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
        translate([0, 0, -base - 1]) cylinder(d = d_central, h = base + a + 2, $fn = 24);
        if (con_tuerca)
            translate([0, 0, -base])
                agujero_tuerca(familia_tuerca, subtipo_tuerca, medida_central, base + a, 0);
        else
            translate([0, 0, -base - 0.5])
                avellanado_tuerca(familia_tuerca, medida_central, prof_av + 0.5);
    }
}

/* ============================================================
   vista: "ensamblada" | "explosionada" | "impresion" | "A" | "B"
   pasos: giro de B respecto de A en pasos de 360/n_dientes
   ============================================================ */
module junta_hirth_plana(
    pasos              = 6,
    vista              = "ensamblada",
    holgura_axial      = 0.2,
    separacion         = 50,
    radio              = _radio,
    n_dientes          = _n_dientes,
    prof_diente        = _prof_diente,
    pendiente          = _pendiente,
    base               = _base,
    largo_extra        = _largo_extra,
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

    echo(str("Hirth plana R=", radio, " n=", n_dientes, ": paso ", paso,
             " grados, tornillo central >= ", 2 * base + holgura_axial, " mm + cabeza/tuerca"));

    module mitad(con_tuerca, fase)
        hirth_plano_mitad(
            con_tuerca = con_tuerca, fase = fase,
            radio = radio, n_dientes = n_dientes, prof_diente = prof_diente,
            pendiente = pendiente, base = base, largo_extra = largo_extra,
            profundidad_hueco = profundidad_hueco,
            cantidad_tornillos = cantidad_tornillos, angulo_tornillo = angulo_tornillo,
            profundidad_pieza = profundidad_pieza,
            diametro = diametro, holgura = holgura, poly_n = poly_n,
            familia_tuerca = familia_tuerca, subtipo_tuerca = subtipo_tuerca,
            medida_tornillo = medida_tornillo, medida_central = medida_central
        );

    if (vista == "A")
        mitad(false, 0);
    else if (vista == "B")
        mitad(true, paso / 2);
    else if (vista == "impresion") {
        mitad(false, 0);
        translate([0, -2.2 * radio - 40, 0]) mitad(true, paso / 2);
    } else {
        mitad(false, 0);
        translate([0, 0, holgura_axial + (vista == "explosionada" ? separacion : 0)])
            rotate([0, 0, pasos * paso]) rotate([180, 0, 0])
                mitad(true, paso / 2);
    }
}


/* ============================================================
   DEMO: familia de tamanos (mas radio -> mas dientes; paso sobre el borde
   de 7 a 10 mm)
   ============================================================ */

// chica: R25, 16 dientes (22.5 grados)
junta_hirth_plana(radio = 25, n_dientes = 16, prof_diente = 6, pasos = 4);

// mediana: R30, 24 dientes (15 grados)
translate([0, 180, 0])
    junta_hirth_plana(radio = 30, n_dientes = 24, prof_diente = 8, pasos = 6);

// grande: R40, 36 dientes (10 grados)
translate([0, 400, 0])
    junta_hirth_plana(radio = 40, n_dientes = 36, prof_diente = 10, pasos = 9);
