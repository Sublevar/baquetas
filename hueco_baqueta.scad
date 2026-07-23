use <tuercas_metricas.scad>;
use <tuerca_UNC-UNF.scad>;
use <tuerca_whitworth.scad>;

/* ============================================================
   PARÁMETROS GENERALES
   ============================================================ */

hueco_principal        = true;
diametro               = 24;     // diámetro de la baqueta/eje (mm)
poly_n                 = 16;
margen                 = .5;
largo_hueco_principal  = 120;
angulo_tornillo        = 0;      // ángulo de arranque del primer tornillo (grados)

// --- 1) Elegí la FAMILIA de rosca/tuerca ---
// "UNC" | "UNF" | "metrica" | "whitworth"
familia_tuerca  = "UNC";

// --- Elegí el SUBTIPO (vocabulario unificado) ---
// "normal" | "delgada" | "autoblocante" | "brida"
// (para UNC/UNF esto se traduce internamente a "jam"/"nylon")
subtipo_tuerca  = "normal";

// Medida del tornillo/rosca:
//   - "metrica"            -> milímetros (ej: 8 para M8)
//   - "UNC" / "UNF" / "whitworth" -> pulgadas decimales (ej: 0.25 = 1/4")
medida_tornillo    = 0.25;
profundidad_pieza  = 12;

// --- 2) Elegí cuántos tornillos (se distribuyen equiespaciados) ---
cantidad_tornillos = 1;      // 1, 2, 3, 4, 6, lo que necesites

ancho_baqueta = 30;           // largo del cilindro macizo (eje Y de la pieza)

d = diametro + margen;
r = d / 2;

/* ============================================================
   NORMALIZACIÓN DE SUBTIPOS ENTRE FAMILIAS
   UNC/UNF usan "jam"/"nylon", metrica/whitworth usan
   "delgada"/"autoblocante". Acá se traduce automáticamente.
   ============================================================ */

function subtipo_interno(familia, subtipo) =
    (familia == "UNC" || familia == "UNF") ?
        (subtipo == "delgada"      ? "jam"   :
         subtipo == "autoblocante" ? "nylon" :
         subtipo) : // "normal" y "brida" ya coinciden
    subtipo; // metrica y whitworth usan el vocabulario tal cual

/* ============================================================
   FUNCIONES AUX: ancho de llave según familia/subtipo/medida
   ============================================================ */

function ancho_tuerca(familia, subtipo, medida) =
    (familia == "UNC" || familia == "UNF") ? tuerca_unc(medida, subtipo_interno(familia, subtipo))[0] :
    (familia == "metrica")                 ? tuerca_metrica(medida, subtipo)[0] :
    (familia == "whitworth")                ? tuerca_whitworth(medida, subtipo)[0] :
    0;

// Grosor de material necesario para alojar la tuerca elegida:
// diámetro del eje (+margen) + 2 veces el ancho de llave de la tuerca.
// Es la misma cuenta que usabas a mano:
//   grosor = d + tuerca_unc(0.25,"normal")[0] * 2;
// Ahora con DEFAULTS: podés llamarla sin argumentos y toma los
// valores globales de arriba, o pisar solo los que necesites:
//   grosor_baqueta()                              -> usa todos los defaults
//   grosor_baqueta(medida = 8, familia = "metrica") -> pisa solo esos dos
function grosor_baqueta(
    diametro = diametro,
    margen   = margen,
    familia  = familia_tuerca,
    subtipo  = subtipo_tuerca,
    medida   = medida_tornillo
) = (diametro + margen) + ancho_tuerca(familia, subtipo, medida) * 2;

c = ancho_tuerca(familia_tuerca, subtipo_tuerca, medida_tornillo);
sagita = r - sqrt(pow(r, 2) - pow(c / 2, 2)) + margen;

echo(str("Tuerca elegida: ", familia_tuerca, " / ", subtipo_tuerca, " ", medida_tornillo, " -> ancho llave: ", c));

/* ============================================================
   DISTRIBUCIÓN RADIAL CON children()
   Reparte "cantidad" copias de lo que le pases como hijo,
   girando alrededor del eje X, a distancia "radio", empezando
   en "angulo_offset".
   ============================================================ */

module distribuir_radial(cantidad, radio, angulo_offset = 0) {
    paso = 360 / cantidad;
    for (i = [0 : cantidad - 1]) {
        rotate([angulo_offset + i * paso, 0, 0])
            translate([0, 0, radio])
                children();
    }
}

/* ============================================================
   SELECTOR DE AGUJERO+TUERCA SEGÚN FAMILIA
   Acá se conecta cada librería real con su nombre correcto.
   ============================================================ */

module agujero_tuerca(familia, subtipo, medida, profundidad_pieza, alivio) {
    if (familia == "UNC" || familia == "UNF") {
        agujero_con_tuerca_unc(
            medida,
            profundidad_pieza = profundidad_pieza,
            tipo   = subtipo_interno(familia, subtipo),
            serie  = familia,
            alivio = alivio
        );
    } else if (familia == "metrica") {
        agujero_con_tuerca_metrica(
            medida,
            tipo = subtipo,
            profundidad_pieza = profundidad_pieza,
            alivio = alivio
        );
    } else if (familia == "whitworth") {
        agujero_con_tuerca_whitworth(
            medida,
            profundidad_pieza = profundidad_pieza,
            tipo = subtipo,
            alivio = alivio
        );
    } else {
        echo(str("ATENCION: familia_tuerca desconocida: ", familia));
    }
}

/* ============================================================
   MÓDULO PRINCIPAL (el hueco / agujeros a restar)
   ============================================================ */

module hueco_baqueta(
    diametro              = diametro,
    margen                = margen,
    largo_hueco_principal = largo_hueco_principal,
    poly_n                = poly_n,
    familia_tuerca        = familia_tuerca,
    subtipo_tuerca        = subtipo_tuerca,
    medida_tornillo       = medida_tornillo,
    cantidad_tornillos    = cantidad_tornillos,
    profundidad_pieza     = profundidad_pieza,
    angulo_tornillo       = angulo_tornillo,
    hueco_principal       = hueco_principal
) {
    d_ = diametro + margen;
    r_ = d_ / 2;
    c_ = ancho_tuerca(familia_tuerca, subtipo_tuerca, medida_tornillo);
    sagita_ = r_ - sqrt(pow(r_, 2) - pow(c_ / 2, 2)) + margen;

    if (hueco_principal) {
        rotate([0, 90, 0])
            cylinder(d = d_, h = largo_hueco_principal, center = true, $fn = poly_n);
    }

    distribuir_radial(cantidad_tornillos, r_, angulo_tornillo)
        agujero_tuerca(familia_tuerca, subtipo_tuerca, medida_tornillo, profundidad_pieza, sagita_);
}

/* ============================================================
   PIEZA MACIZA (cilindro exterior ya con grosor calculado)
   ============================================================ */

module baqueta_solida(
    diametro              = diametro,
    margen                = margen,
    familia_tuerca        = familia_tuerca,
    subtipo_tuerca        = subtipo_tuerca,
    medida_tornillo       = medida_tornillo,
    ancho_baqueta         = ancho_baqueta,
    poly_n                = poly_n
) {
    g = grosor_baqueta(diametro, margen, familia_tuerca, subtipo_tuerca, medida_tornillo);
    rotate([0, 90, 0])
        cylinder(d = g, h = ancho_baqueta, center = true, $fn = poly_n);
}

/* ============================================================
   USO
   ============================================================ */

difference() {
    baqueta_solida();
    hueco_baqueta();
}

// --- Ejemplos de otras combinaciones, solo cambiando parámetros ---
// difference() {
//     baqueta_solida(familia_tuerca = "metrica", subtipo_tuerca = "autoblocante", medida_tornillo = 6);
//     hueco_baqueta(cantidad_tornillos = 6, familia_tuerca = "metrica", subtipo_tuerca = "autoblocante", medida_tornillo = 6);
// }

// grosor_baqueta() con distintos overrides:
// echo(grosor_baqueta());                                 // todo por defecto
// echo(grosor_baqueta(medida = 8, familia = "metrica"));   // pisa solo medida y familia
