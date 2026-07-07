// =====================================================
// CALCULADORA - TUERCAS WHITWORTH (BSW / BS 1083)
// El diámetro de rosca se ingresa en PULGADAS (decimal)
// Valores de referencia - verificar norma BS 1083 exacta
// si es crítico (no tan estandarizada públicamente como
// DIN/ISO para las variantes delgada/autoblocante/brida)
// =====================================================
PULGADA2 = 25.4;
function pulg_a_mm2(p) = p * PULGADA2;

// -----------------------------------------------------
// Tuerca hexagonal NORMAL (BS 1083)
// [ancho_entre_caras_mm, espesor_mm]
// -----------------------------------------------------
function tuerca_whitworth_normal(D_pulg) =
    D_pulg <= 1/8  ? [7.92,  2.4]  :
    D_pulg <= 3/16 ? [9.52,  3.2]  :
    D_pulg <= 1/4  ? [11.30, 5.1]  :
    D_pulg <= 5/16 ? [13.34, 6.4]  :
    D_pulg <= 3/8  ? [15.24, 7.9]  :
    D_pulg <= 7/16 ? [18.03, 9.2]  :
    D_pulg <= 1/2  ? [20.65, 10.3] :
    D_pulg <= 5/8  ? [25.65, 12.7] :
    D_pulg <= 3/4  ? [30.61, 15.5] :
    [pulg_a_mm2(D_pulg) * 1.8, pulg_a_mm2(D_pulg) * 0.9];

// -----------------------------------------------------
// Tuerca hexagonal DELGADA/JAM (aprox., mismo ancho caras,
// espesor reducido ~55-60% de la normal)
// -----------------------------------------------------
function tuerca_whitworth_delgada(D_pulg) =
    D_pulg <= 1/8  ? [7.92,  1.6]  :
    D_pulg <= 3/16 ? [9.52,  2.0]  :
    D_pulg <= 1/4  ? [11.30, 3.0]  :
    D_pulg <= 5/16 ? [13.34, 3.6]  :
    D_pulg <= 3/8  ? [15.24, 4.5]  :
    D_pulg <= 7/16 ? [18.03, 5.2]  :
    D_pulg <= 1/2  ? [20.65, 5.8]  :
    D_pulg <= 5/8  ? [25.65, 7.1]  :
    D_pulg <= 3/4  ? [30.61, 8.7]  :
    [pulg_a_mm2(D_pulg) * 1.8, pulg_a_mm2(D_pulg) * 0.5];

// -----------------------------------------------------
// Tuerca AUTOBLOCANTE con nylon (aprox., más alta que la
// normal por el inserto). Valores de REFERENCIA.
// -----------------------------------------------------
function tuerca_whitworth_nylon(D_pulg) =
    D_pulg <= 1/8  ? [7.92,  4.0]  :
    D_pulg <= 3/16 ? [9.52,  4.8]  :
    D_pulg <= 1/4  ? [11.30, 7.0]  :
    D_pulg <= 5/16 ? [13.34, 8.5]  :
    D_pulg <= 3/8  ? [15.24, 10.3] :
    D_pulg <= 7/16 ? [18.03, 11.9] :
    D_pulg <= 1/2  ? [20.65, 13.3] :
    D_pulg <= 5/8  ? [25.65, 16.4] :
    [pulg_a_mm2(D_pulg) * 1.8, pulg_a_mm2(D_pulg) * 1.4];

// -----------------------------------------------------
// Tuerca CON BRIDA (aprox., no muy común en Whitworth
// original, pero se ofrece por consistencia)
// [ancho_entre_caras, espesor, diametro_brida]
// -----------------------------------------------------
function tuerca_whitworth_brida(D_pulg) =
    D_pulg <= 3/16 ? [9.52,  4.8,  15.0] :
    D_pulg <= 1/4  ? [11.30, 7.0,  17.5] :
    D_pulg <= 5/16 ? [13.34, 8.0,  20.5] :
    D_pulg <= 3/8  ? [15.24, 9.0,  23.5] :
    D_pulg <= 1/2  ? [20.65, 12.5, 30.0] :
    [pulg_a_mm2(D_pulg) * 1.8, pulg_a_mm2(D_pulg) * 1.0, pulg_a_mm2(D_pulg) * 3.9];

// -----------------------------------------------------
// FUNCIÓN SELECTORA GENERAL
// Devuelve siempre [ancho_caras, espesor, diametro_brida]
// -----------------------------------------------------
function tuerca_whitworth(D_pulg, tipo = "normal") =
    tipo == "normal"       ? [tuerca_whitworth_normal(D_pulg)[0],  tuerca_whitworth_normal(D_pulg)[1],  0] :
    tipo == "delgada"      ? [tuerca_whitworth_delgada(D_pulg)[0], tuerca_whitworth_delgada(D_pulg)[1], 0] :
    tipo == "autoblocante" ? [tuerca_whitworth_nylon(D_pulg)[0],   tuerca_whitworth_nylon(D_pulg)[1],   0] :
    tipo == "brida"        ? tuerca_whitworth_brida(D_pulg) :
    [tuerca_whitworth_normal(D_pulg)[0], tuerca_whitworth_normal(D_pulg)[1], 0];

// =====================================================
// MÓDULO: BOLSILLO HEXAGONAL PARA TUERCA
// =====================================================
module bolsillo_tuerca_whitworth(
    diametro_rosca_pulg,
    tipo = "normal",
    profundidad_bolsillo = -1,   // -1 = usar espesor estándar según norma
    holgura = 0.3,
    holgura_altura = 0.2
) {
    datos = tuerca_whitworth(diametro_rosca_pulg, tipo);
    ancho_caras = datos[0];
    espesor_estandar = datos[1];

    profundidad_real = profundidad_bolsillo < 0 ? espesor_estandar : profundidad_bolsillo;
    radio_hex = (ancho_caras/2 + holgura) / cos(30);

    translate([0, 0, 0])
        cylinder(h = profundidad_real + holgura_altura,
                 r = radio_hex,
                 $fn = 6);

    if (tipo == "brida" && datos[2] > 0) {
        translate([0, 0, 0])
            cylinder(h = profundidad_real * 0.4,
                     r = (datos[2]/2) + holgura);
    }
}

// =====================================================
// MÓDULO: AGUJERO PASANTE PARA EL VÁSTAGO
// =====================================================
module agujero_pasante_tuerca_whitworth(
    diametro_rosca_pulg,
    profundidad,
    profundidad_bolsillo = 0,
    holgura = 0.5,
    profundidad_abs = true
) {
    diametro_rosca_mm = pulg_a_mm2(diametro_rosca_pulg);

    if (profundidad_abs)
        translate([0, 0, profundidad_bolsillo])
            cylinder(h = profundidad - profundidad_bolsillo,
                     r = (diametro_rosca_mm/2) + holgura);
    else
        translate([0, 0, profundidad_bolsillo])
            cylinder(h = profundidad,
                     r = (diametro_rosca_mm/2) + holgura);
}

// =====================================================
// MÓDULO COMBINADO: TUERCA EMBUTIDA + AGUJERO PASANTE
// profundidad_pieza OBLIGATORIO (para booleanos reales)
// profundidad_bolsillo OPCIONAL (default = norma)
// =====================================================
module agujero_con_tuerca_whitworth(
    diametro_rosca_pulg,
    profundidad_pieza,             // OBLIGATORIO: espesor real de la pieza
    tipo = "normal",                 // "normal" | "delgada" | "autoblocante" | "brida"
    profundidad_bolsillo = -1,       // -1 = usar espesor estándar de la tabla
    holgura_tuerca = 0.3,
    holgura_pasante = 0.5,
    holgura_altura = 0.2,
    margen_corte = 0.5,               // sobresalto para evitar z-fighting
    profundidad_abs = true
) {
    datos = tuerca_whitworth(diametro_rosca_pulg, tipo);
    espesor_estandar = datos[1];

    bolsillo_real = profundidad_bolsillo < 0 ? espesor_estandar : profundidad_bolsillo;

    bolsillo_tuerca_whitworth(
        diametro_rosca_pulg = diametro_rosca_pulg,
        tipo = tipo,
        profundidad_bolsillo = bolsillo_real,
        holgura = holgura_tuerca,
        holgura_altura = holgura_altura
    );

    agujero_pasante_tuerca_whitworth(
        diametro_rosca_pulg = diametro_rosca_pulg,
        profundidad = profundidad_pieza + margen_corte,
        profundidad_bolsillo = bolsillo_real,
        holgura = holgura_pasante,
        profundidad_abs = profundidad_abs
    );
}

// Utilidades
function ancho_caras_tuerca(D_pulg, tipo = "normal") = tuerca_whitworth(D_pulg, tipo)[0];
function espesor_tuerca(D_pulg, tipo = "normal") = tuerca_whitworth(D_pulg, tipo)[1];

// =====================================================
// EJEMPLOS CON CASOS CONCRETOS - tuerca_whitworth(D, tipo)
// =====================================================
espesor_pieza2 = 12;
echo("5/16 normal:", tuerca_whitworth(5/16, "normal"));
translate([-60, 40, 0])
    agujero_con_tuerca_whitworth(5/16, profundidad_pieza = 12, tipo="normal");

echo("5/16 delgada:", tuerca_whitworth(5/16, "delgada"));
translate([-15, 40, 0])
    agujero_con_tuerca_whitworth(5/16, profundidad_pieza = 12, tipo="delgada");

echo("5/16 autoblocante:", tuerca_whitworth(5/16, "autoblocante"));
translate([30, 40, 0])
    agujero_con_tuerca_whitworth(5/16, profundidad_pieza = 12, tipo="autoblocante");

echo("5/16 brida:", tuerca_whitworth(5/16, "brida"));
translate([75, 40, 0])
    agujero_con_tuerca_whitworth(5/16, profundidad_pieza = 12, tipo="brida");