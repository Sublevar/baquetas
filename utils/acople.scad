use <../hueco_baqueta.scad>

/* ============================================================
   ACOPLE CIEGO PARA BAQUETA
   Pieza base compartida por apoyos.scad, patas.scad y hirth.scad.

   Eje del acople = X. Cuerpo desde x=0 hasta x=largo.
   La boca de la baqueta esta en x=largo y el fondo del hueco
   en x=largo-profundidad_hueco (queda macizo por debajo).

   Se dividen en dos modulos (cuerpo / hueco) igual que
   baqueta_solida / hueco_baqueta, para poder unir otras piezas
   al cuerpo ANTES de restar el hueco:

       difference() {
           union() { acople_cuerpo(...); mi_pieza(); }
           acople_hueco(...);
       }

   Para un acople vertical con la boca hacia arriba (+Z):
       rotate([0, -90, 0]) acople_cuerpo(...);
   (con angulo_tornillo = 0 el tornillo sale hacia -X)

   posiciones: lista de fracciones (0 = fondo, 1 = boca) donde
   va un anillo de tornillos de presion sobre la baqueta.
   ============================================================ */

module acople_cuerpo(
    largo           = 60,
    diametro        = 24,
    holgura         = 0.5,
    poly_n          = 16,
    familia_tuerca  = "UNC",
    subtipo_tuerca  = "normal",
    medida_tornillo = 0.1875
) {
    g = grosor_baqueta(diametro, holgura, familia_tuerca, subtipo_tuerca, medida_tornillo);
    rotate([0, 90, 0])
        cylinder(d = g, h = largo, $fn = poly_n);
}

module acople_hueco(
    largo               = 60,
    profundidad_hueco   = 45,
    diametro            = 24,
    holgura             = 0.5,
    poly_n              = 16,
    cantidad_tornillos  = 1,
    posiciones          = [0.5],
    angulo_tornillo     = 0,
    profundidad_pieza   = 20,
    familia_tuerca      = "UNC",
    subtipo_tuerca      = "normal",
    medida_tornillo     = 0.1875
) {
    d_ = diametro + holgura;
    x0 = largo - profundidad_hueco;

    // hueco ciego de la baqueta, abierto en la boca
    translate([x0, 0, 0]) rotate([0, 90, 0])
        cylinder(d = d_, h = profundidad_hueco + 1, $fn = poly_n);

    // tornillos de presion (solo agujero + tuerca + avellanado)
    for (p = posiciones)
        translate([x0 + p * profundidad_hueco, 0, 0])
            hueco_baqueta(
                hueco_principal    = false,
                cantidad_tornillos = cantidad_tornillos,
                angulo_tornillo    = angulo_tornillo,
                profundidad_pieza  = profundidad_pieza,
                diametro           = diametro,
                holgura            = holgura,
                poly_n             = poly_n,
                familia_tuerca     = familia_tuerca,
                subtipo_tuerca     = subtipo_tuerca,
                medida_tornillo    = medida_tornillo
            );
}

// Diametro del vastago en mm (UNC/UNF/whitworth vienen en pulgadas)
function diametro_tornillo_mm(familia, medida) =
    familia == "metrica" ? medida : medida * 25.4;
