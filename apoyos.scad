use <hueco_baqueta.scad>
use <utils/acople.scad>

/* ============================================================
   APOYOS
     - acople_pared:    fija una baqueta a una pared
     - apoyo_estante:   collar que se prensa a una baqueta vertical
                        y sostiene una (o mas) bandejas de estante
   Ambos usan el acople ciego de utils/acople.scad (mismo hueco,
   misma tuerca y avellanado que juntas.scad).
   ============================================================ */

// Baqueta / eje
_diametro        = 24;
_holgura         = 0.5;
_poly_n          = 16;

// Tornillo de presion sobre la baqueta
_familia_tuerca  = "UNC";
_subtipo_tuerca  = "normal";
_medida_tornillo = 0.1875;
_profundidad     = 20;

// Tornillos de fijacion a pared / estante (madera, mm)
_d_tornillo_fijacion = 4.5;
_d_cabeza_fijacion   = 9;

/* ============================================================
   ACOPLE PARA PARED
   modo "perpendicular": la baqueta entra de frente a la pared.
        Placa redonda + cono de refuerzo + acople ciego.
   modo "paralelo": la baqueta corre a lo largo de la pared,
        separada por un taco. Placa rectangular + cuna, hueco pasante.
   El eje de la pieza es X, la pared esta en x=0 y la pieza
   sale hacia +X. En modo perpendicular los tornillos de presion apuntan a -Y (90).
   ============================================================ */
module acople_pared(
    modo               = "perpendicular",   // "perpendicular" | "paralelo"
    largo              = 60,     // perpendicular: largo del acople; paralelo: largo de la cuna
    profundidad_hueco  = 45,     // solo perpendicular
    espesor_placa      = 6,
    margen_placa       = 16,     // placa que sobresale del cuerpo
    cantidad_fijaciones = 4,
    d_fijacion         = _d_tornillo_fijacion,
    d_cabeza           = _d_cabeza_fijacion,
    cantidad_tornillos = 1,
    angulo_tornillo    = 90,
    profundidad_pieza  = _profundidad,
    diametro           = _diametro,
    holgura            = _holgura,
    poly_n             = _poly_n,
    familia_tuerca     = _familia_tuerca,
    subtipo_tuerca     = _subtipo_tuerca,
    medida_tornillo    = _medida_tornillo
) {
    g = grosor_baqueta(diametro, holgura, familia_tuerca, subtipo_tuerca, medida_tornillo);

    // agujeros de fijacion con cabeza avellanada hacia afuera (+X)
    module fijacion()
        rotate([0, 90, 0]) {
            translate([0, 0, -1]) cylinder(d = d_fijacion, h = espesor_placa + 2, $fn = 20);
            translate([0, 0, espesor_placa - (d_cabeza - d_fijacion) / 2])
                cylinder(d1 = d_fijacion, d2 = d_cabeza, h = (d_cabeza - d_fijacion) / 2 + 0.01, $fn = 20);
            translate([0, 0, espesor_placa])
                cylinder(d = d_cabeza, h = g, $fn = 20);
        }

    if (modo == "perpendicular") {
        d_placa = g + 2 * margen_placa;
        r_fij   = g / 2 + margen_placa / 2 + 2;
        difference() {
            union() {
                rotate([0, 90, 0]) cylinder(d = d_placa, h = espesor_placa, $fn = 48);
                // cono de refuerzo entre placa y cuerpo
                translate([espesor_placa, 0, 0]) rotate([0, 90, 0])
                    cylinder(d1 = g + margen_placa, d2 = g, h = margen_placa, $fn = poly_n);
                acople_cuerpo(
                    largo = largo, diametro = diametro, holgura = holgura, poly_n = poly_n,
                    familia_tuerca = familia_tuerca, subtipo_tuerca = subtipo_tuerca,
                    medida_tornillo = medida_tornillo
                );
            }
            acople_hueco(
                largo = largo, profundidad_hueco = profundidad_hueco,
                cantidad_tornillos = cantidad_tornillos, angulo_tornillo = angulo_tornillo,
                profundidad_pieza = profundidad_pieza,
                diametro = diametro, holgura = holgura, poly_n = poly_n,
                familia_tuerca = familia_tuerca, subtipo_tuerca = subtipo_tuerca,
                medida_tornillo = medida_tornillo
            );
            for (i = [0 : cantidad_fijaciones - 1])
                rotate([i * 360 / cantidad_fijaciones + 45, 0, 0])
                    translate([0, 0, r_fij]) fijacion();
        }
    } else {
        // paralelo: la baqueta corre a lo largo de Y, centro a x = espesor + g/2
        ancho = g + 2 * margen_placa;
        cx    = espesor_placa + g / 2;
        difference() {
            union() {
                translate([0, -largo / 2, -ancho / 2]) cube([espesor_placa, largo, ancho]);
                // cuna: el cuerpo cilindrico unido a la placa
                hull() {
                    translate([espesor_placa / 2, 0, 0])
                        cube([espesor_placa, largo, g * 0.6], center = true);
                    translate([cx, 0, 0]) rotate([90, 0, 0])
                        cylinder(d = g, h = largo, center = true, $fn = poly_n);
                }
            }
            // hueco pasante de la baqueta
            translate([cx, 0, 0]) rotate([90, 0, 0])
                cylinder(d = diametro + holgura, h = largo + 2, center = true, $fn = poly_n);
            // tornillo de presion al frente (+X) de la baqueta
            translate([cx, 0, 0]) rotate([0, 90, 0]) rotate([0, 0, 90])
                hueco_baqueta(
                    hueco_principal = false, cantidad_tornillos = 1,
                    angulo_tornillo = 0,
                    profundidad_pieza = profundidad_pieza,
                    diametro = diametro, holgura = holgura, poly_n = poly_n,
                    familia_tuerca = familia_tuerca, subtipo_tuerca = subtipo_tuerca,
                    medida_tornillo = medida_tornillo
                );
            // fijaciones a pared, a cada lado de la cuna
            for (z = [-1, 1], y = [-1, 1])
                translate([0, y * (largo / 2 - margen_placa), z * (g / 2 + margen_placa / 2 + 2)])
                    fijacion();
        }
    }
}

/* ============================================================
   APOYO PARA ESTANTES
   Collar vertical (eje Z) que se prensa a una baqueta con
   tornillos de presion y lleva uno o mas brazos horizontales
   donde apoya la tabla del estante.

   brazos: lista de angulos (grados alrededor de Z) -> [0] un brazo,
           [0, 90] esquinero, [0, 180] pasante entre dos estantes, etc.
   El brazo termina en un tope (labio) para que el estante no se corra
   y tiene dos agujeros para atornillar la tabla desde abajo.
   Los tornillos de presion del collar apuntan al lado opuesto al
   primer brazo.
   ============================================================ */
module apoyo_estante(
    alto               = 50,     // alto del collar
    brazos             = [0],
    largo_brazo        = 90,     // desde el eje de la baqueta
    ancho_brazo        = 40,
    espesor_brazo      = 10,
    alto_labio         = 8,
    ancho_labio        = 5,
    refuerzo           = true,   // cartela triangular bajo el brazo
    largo_refuerzo     = 0.75,   // fraccion del largo del brazo
    alto_refuerzo      = 35,
    d_fijacion         = _d_tornillo_fijacion,
    d_cabeza           = _d_cabeza_fijacion,
    cantidad_tornillos = 1,
    posiciones         = [0.25, 0.75],
    profundidad_pieza  = _profundidad,
    diametro           = _diametro,
    holgura            = _holgura,
    poly_n             = _poly_n,
    familia_tuerca     = _familia_tuerca,
    subtipo_tuerca     = _subtipo_tuerca,
    medida_tornillo    = _medida_tornillo
) {
    g = grosor_baqueta(diametro, holgura, familia_tuerca, subtipo_tuerca, medida_tornillo);
    dir0 = len(brazos) > 0 ? brazos[0] : 0;

    module brazo() {
        // placa superior (apoyo del estante) -- arranca en el eje
        translate([0, -ancho_brazo / 2, alto - espesor_brazo])
            cube([largo_brazo, ancho_brazo, espesor_brazo]);
        // labio de tope al final
        translate([largo_brazo - ancho_labio, -ancho_brazo / 2, alto - espesor_brazo])
            cube([ancho_labio, ancho_brazo, espesor_brazo + alto_labio]);
        // cartela bajo el brazo, en el plano medio
        if (refuerzo)
            translate([0, 0, alto - espesor_brazo])
                rotate([90, 0, 0])
                    linear_extrude(height = 8, center = true)
                        polygon([[0, 0], [largo_brazo * largo_refuerzo, 0], [g / 2 - 1, -alto_refuerzo], [0, -alto_refuerzo]]);
    }

    // agujeros para atornillar la tabla desde abajo (cabeza abajo, rosca hacia arriba)
    module agujeros_tabla()
        for (y = [-1, 1])
            translate([largo_brazo - ancho_labio - 14, y * ancho_brazo / 4, alto - espesor_brazo]) {
                translate([0, 0, -1]) cylinder(d = d_fijacion, h = espesor_brazo + 2, $fn = 20);
                translate([0, 0, -1]) cylinder(d = d_cabeza, h = espesor_brazo / 2, $fn = 20);
            }

    difference() {
        union() {
            // collar vertical: acople_cuerpo rotado para que el eje X pase a Z
            rotate([0, -90, 0])
                acople_cuerpo(
                    largo = alto, diametro = diametro, holgura = holgura, poly_n = poly_n,
                    familia_tuerca = familia_tuerca, subtipo_tuerca = subtipo_tuerca,
                    medida_tornillo = medida_tornillo
                );
            for (a = brazos) rotate([0, 0, a]) brazo();
        }
        // hueco pasante y tornillos de presion
        rotate([0, -90, 0])
            acople_hueco(
                largo = alto + 1, profundidad_hueco = alto + 2,
                cantidad_tornillos = cantidad_tornillos, posiciones = posiciones,
                angulo_tornillo = 0,
                profundidad_pieza = profundidad_pieza,
                diametro = diametro, holgura = holgura, poly_n = poly_n,
                familia_tuerca = familia_tuerca, subtipo_tuerca = subtipo_tuerca,
                medida_tornillo = medida_tornillo
            );
        for (a = brazos) rotate([0, 0, a]) agujeros_tabla();
    }
}


/* ============================================================
   DEMO
   ============================================================ */

// Acople a pared, baqueta de frente
acople_pared();

// Acople a pared, baqueta paralela a la pared
translate([0, 150, 0])
    acople_pared(modo = "paralelo", largo = 70);

// Apoyo de estante, un brazo
translate([150, 0, 0])
    apoyo_estante();

// Apoyo de estante esquinero (dos brazos a 90)
translate([150, 150, 0])
    apoyo_estante(brazos = [0, 90]);
