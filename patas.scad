use <hueco_baqueta.scad>
use <utils/acople.scad>

/* ============================================================
   PATAS
     - pata_base:    pie de base circular con acople para la baqueta
                     (palo de escoba) hacia arriba
     - pata_rotula:  igual, pero con una rotula intermedia entre el
                     acople y el pie, para que la pata copie el piso

   Eje vertical = Z, piso en z=0, la baqueta entra por arriba.
   Usan el acople ciego de utils/acople.scad.
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

// Tornillos de fijacion al piso (opcional, mm)
_d_tornillo_fijacion = 4.5;
_d_cabeza_fijacion   = 9;

/* ============================================================
   BASE CIRCULAR
   Disco plano + cono de refuerzo que sube hasta d_cuerpo.
   Rebaje inferior opcional para pegar una goma antideslizante
   y agujeros avellanados para fijarla al piso.
   Devuelve solo el solido (los agujeros van en base_circular_huecos).
   ============================================================ */
module base_circular(
    d_base     = 110,
    espesor    = 6,
    d_cuerpo   = 46,
    alto_cono  = 14,
    margen     = 12      // cuanto sobresale el arranque del cono del cuerpo
) {
    cylinder(d = d_base, h = espesor, $fn = 64);
    translate([0, 0, espesor - 0.01])
        cylinder(d1 = d_cuerpo + 2 * margen, d2 = d_cuerpo, h = alto_cono, $fn = 48);
}

module base_circular_huecos(
    d_base         = 110,
    espesor        = 6,
    d_cuerpo       = 46,
    margen         = 12,
    agujeros       = 3,
    d_fijacion     = _d_tornillo_fijacion,
    d_cabeza       = _d_cabeza_fijacion,
    rebaje_goma    = true,
    d_goma         = 70,
    prof_goma      = 1.5
) {
    // rebaje inferior para goma
    if (rebaje_goma)
        translate([0, 0, -1]) cylinder(d = d_goma, h = prof_goma + 1, $fn = 48);

    // agujeros avellanados en la corona exterior
    r_fij = (d_base / 2 + (d_cuerpo + 2 * margen) / 2) / 2;
    if (agujeros > 0)
        for (i = [0 : agujeros - 1])
            rotate([0, 0, i * 360 / agujeros + 90])
                translate([r_fij, 0, 0]) {
                    translate([0, 0, -1]) cylinder(d = d_fijacion, h = espesor + 2, $fn = 20);
                    translate([0, 0, espesor - (d_cabeza - d_fijacion) / 2])
                        cylinder(d1 = d_fijacion, d2 = d_cabeza, h = (d_cabeza - d_fijacion) / 2 + 0.01, $fn = 20);
                    translate([0, 0, espesor])
                        cylinder(d = d_cabeza, h = 10, $fn = 20);
                }
}

/* ============================================================
   PATA CON BASE CIRCULAR
   largo:  altura total del acople desde el piso
   ============================================================ */
module pata_base(
    largo              = 70,
    profundidad_hueco  = 45,
    d_base             = 110,
    espesor_base       = 6,
    alto_cono          = 14,
    agujeros           = 3,
    rebaje_goma        = true,
    d_goma             = 70,
    prof_goma          = 1.5,
    cantidad_tornillos = 1,
    angulo_tornillo    = 0,
    profundidad_pieza  = _profundidad,
    diametro           = _diametro,
    holgura            = _holgura,
    poly_n             = _poly_n,
    familia_tuerca     = _familia_tuerca,
    subtipo_tuerca     = _subtipo_tuerca,
    medida_tornillo    = _medida_tornillo
) {
    g = grosor_baqueta(diametro, holgura, familia_tuerca, subtipo_tuerca, medida_tornillo);

    difference() {
        union() {
            base_circular(d_base, espesor_base, g, alto_cono);
            rotate([0, -90, 0])
                acople_cuerpo(
                    largo = largo, diametro = diametro, holgura = holgura, poly_n = poly_n,
                    familia_tuerca = familia_tuerca, subtipo_tuerca = subtipo_tuerca,
                    medida_tornillo = medida_tornillo
                );
        }
        rotate([0, -90, 0])
            acople_hueco(
                largo = largo, profundidad_hueco = profundidad_hueco,
                cantidad_tornillos = cantidad_tornillos, angulo_tornillo = angulo_tornillo,
                profundidad_pieza = profundidad_pieza,
                diametro = diametro, holgura = holgura, poly_n = poly_n,
                familia_tuerca = familia_tuerca, subtipo_tuerca = subtipo_tuerca,
                medida_tornillo = medida_tornillo
            );
        base_circular_huecos(d_base, espesor_base, g, 12, agujeros,
                             rebaje_goma = rebaje_goma, d_goma = d_goma, prof_goma = prof_goma);
    }
}

/* ============================================================
   ROTULA
   Dos piezas que se encastran a presion (no hay que armar nada
   mas que empujar la bola dentro de la copa):

   rotula_vastago: acople para la baqueta (boca arriba) + cuello + bola.
       Origen = centro de la bola.
   rotula_copa:    base circular + copa esferica con boca mas chica que
       la bola y ranuras radiales para que ceda al encastrar.
       Origen = piso; el centro de la bola queda en z = z_centro_rotula().

   holgura_rotula: luz radial entre bola y copa (0.3-0.5 para pico 0.4,
                   subirla para pico 0.8).
   fraccion_boca:  altura de la boca sobre el ecuador de la bola, como
                   fraccion del radio (menor = mas abierta, mas
                   inclinacion, menos retencion y menos voladizo).
   ============================================================ */
function radio_copa(d_bola, holgura_rotula) = d_bola / 2 + holgura_rotula;
function z_centro_rotula(d_bola, holgura_rotula, espesor_base, piso_copa) =
    espesor_base + piso_copa + radio_copa(d_bola, holgura_rotula);

// inclinacion maxima antes de que el cuello toque el borde de la boca
function inclinacion_maxima(d_bola, holgura_rotula, fraccion_boca, d_cuello) =
    let(rc = radio_copa(d_bola, holgura_rotula),
        hr = fraccion_boca * rc,
        ro = sqrt(rc * rc - hr * hr))
    acos((d_cuello / 2) / sqrt(ro * ro + hr * hr)) - atan(hr / ro);

module rotula_vastago(
    d_bola             = 32,
    d_cuello           = 13,
    plano_bola         = 3,     // se aplana la base de la bola para imprimirla apoyada
    largo              = 70,
    profundidad_hueco  = 45,
    z_acople           = 27,    // altura de la base del acople sobre el centro de la bola
    cantidad_tornillos = 1,
    angulo_tornillo    = 0,
    profundidad_pieza  = _profundidad,
    diametro           = _diametro,
    holgura            = _holgura,
    poly_n             = _poly_n,
    familia_tuerca     = _familia_tuerca,
    subtipo_tuerca     = _subtipo_tuerca,
    medida_tornillo    = _medida_tornillo
) {
    difference() {
        union() {
            intersection() {
                sphere(d = d_bola, $fn = 48);
                translate([-d_bola, -d_bola, -d_bola / 2 + plano_bola])
                    cube(2 * d_bola);
            }
            cylinder(d = d_cuello, h = z_acople + 1, $fn = 32);
            translate([0, 0, z_acople]) rotate([0, -90, 0])
                acople_cuerpo(
                    largo = largo, diametro = diametro, holgura = holgura, poly_n = poly_n,
                    familia_tuerca = familia_tuerca, subtipo_tuerca = subtipo_tuerca,
                    medida_tornillo = medida_tornillo
                );
        }
        translate([0, 0, z_acople]) rotate([0, -90, 0])
            acople_hueco(
                largo = largo, profundidad_hueco = profundidad_hueco,
                cantidad_tornillos = cantidad_tornillos, angulo_tornillo = angulo_tornillo,
                profundidad_pieza = profundidad_pieza,
                diametro = diametro, holgura = holgura, poly_n = poly_n,
                familia_tuerca = familia_tuerca, subtipo_tuerca = subtipo_tuerca,
                medida_tornillo = medida_tornillo
            );
    }
}

module rotula_copa(
    d_bola          = 32,
    holgura_rotula  = 0.4,
    fraccion_boca   = 0.45,
    pared           = 7,
    piso_copa       = 4,
    ranuras         = 6,
    ancho_ranura    = 1.6,
    d_base          = 110,
    espesor_base    = 6,
    alto_cono       = 14,
    agujeros        = 3,
    rebaje_goma     = true,
    d_goma          = 70,
    prof_goma       = 1.5
) {
    rc = radio_copa(d_bola, holgura_rotula);
    zc = z_centro_rotula(d_bola, holgura_rotula, espesor_base, piso_copa);
    hr = fraccion_boca * rc;
    d_ext = 2 * (rc + pared);

    difference() {
        union() {
            base_circular(d_base, espesor_base, d_ext, alto_cono);
            cylinder(d = d_ext, h = zc + hr, $fn = 48);
        }
        translate([0, 0, zc]) sphere(r = rc, $fn = 48);
        // sobre la boca, despejar todo
        translate([0, 0, zc + hr]) cylinder(d = d_ext + 1, h = 50);
        // ranuras radiales desde la boca hasta debajo del ecuador
        for (i = [0 : ranuras - 1])
            rotate([0, 0, i * 360 / ranuras])
                translate([0, -ancho_ranura / 2, zc - 0.2 * rc])
                    cube([d_ext, ancho_ranura, 0.2 * rc + hr + 1]);
        base_circular_huecos(d_base, espesor_base, d_ext, 12, agujeros,
                             rebaje_goma = rebaje_goma, d_goma = d_goma, prof_goma = prof_goma);
    }
}

/* ============================================================
   PATA CON ROTULA
   vista:       "ensamblada" | "partes" (para imprimir) | "vastago" | "copa"
   inclinacion: grados de la pata en la vista ensamblada
   ============================================================ */
module pata_rotula(
    vista              = "ensamblada",
    inclinacion        = 0,
    d_bola             = 32,
    d_cuello           = 13,
    holgura_rotula     = 0.4,
    fraccion_boca      = 0.45,
    largo              = 70,
    profundidad_hueco  = 45,
    d_base             = 110,
    espesor_base       = 6,
    alto_cono          = 14,
    agujeros           = 3,
    rebaje_goma        = true,
    d_goma             = 70,
    cantidad_tornillos = 1,
    angulo_tornillo    = 0,
    profundidad_pieza  = _profundidad,
    diametro           = _diametro,
    holgura            = _holgura,
    poly_n             = _poly_n,
    familia_tuerca     = _familia_tuerca,
    subtipo_tuerca     = _subtipo_tuerca,
    medida_tornillo    = _medida_tornillo
) {
    plano = 3;
    piso_copa = 4;
    zc = z_centro_rotula(d_bola, holgura_rotula, espesor_base, piso_copa);

    echo(str("Rotula: centro a z=", zc, " mm, inclinacion maxima ~",
             inclinacion_maxima(d_bola, holgura_rotula, fraccion_boca, d_cuello), " grados"));

    module vastago()
        rotula_vastago(
            d_bola = d_bola, d_cuello = d_cuello, plano_bola = plano,
            largo = largo, profundidad_hueco = profundidad_hueco,
            cantidad_tornillos = cantidad_tornillos, angulo_tornillo = angulo_tornillo,
            profundidad_pieza = profundidad_pieza,
            diametro = diametro, holgura = holgura, poly_n = poly_n,
            familia_tuerca = familia_tuerca, subtipo_tuerca = subtipo_tuerca,
            medida_tornillo = medida_tornillo
        );

    module copa()
        rotula_copa(
            d_bola = d_bola, holgura_rotula = holgura_rotula, fraccion_boca = fraccion_boca,
            piso_copa = piso_copa, d_base = d_base, espesor_base = espesor_base,
            alto_cono = alto_cono, agujeros = agujeros, rebaje_goma = rebaje_goma, d_goma = d_goma
        );

    if (vista == "vastago")
        vastago();
    else if (vista == "copa")
        copa();
    else if (vista == "partes") {
        copa();
        // el vastago se imprime apoyado sobre el plano de la bola
        translate([d_base + 40, 0, d_bola / 2 - plano]) vastago();
    } else {
        copa();
        translate([0, 0, zc]) rotate([inclinacion, 0, 0]) vastago();
    }
}


/* ============================================================
   DEMO
   ============================================================ */

// Pata simple con base circular
pata_base();

// Pata con rotula, recta
translate([160, 0, 0])
    pata_rotula();

// Pata con rotula, inclinada
translate([320, 0, 0])
    pata_rotula(inclinacion = 25);

// Partes para imprimir
translate([0, 200, 0])
    pata_rotula(vista = "partes");
