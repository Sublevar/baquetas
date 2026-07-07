// =====================================================
// CALCULADORA - TUERCAS UNC/UNF (ANSI/ASME B18.2.2)
// El diámetro nominal se ingresa en PULGADAS (decimal)
// Ej: 1/4" = 0.25 , 3/8" = 0.375 , 1/2" = 0.5
// La serie (UNC/UNF) NO afecta las dimensiones exteriores
// de la tuerca (ancho entre caras / espesor) - solo el paso
// de rosca, por lo que aquí es un dato informativo.
// =====================================================

PULGADA3 = 25.4;
function pulg_a_mm3(p) = p * PULGADA3;

// -----------------------------------------------------
// Tuerca hexagonal NORMAL (ANSI B18.2.2 - Hex Nut)
// [ancho_entre_caras_mm, espesor_mm]
// (valores tomados de tabla ANSI en pulgadas, convertidos a mm)
// -----------------------------------------------------
function tuerca_unc_normal(D_pulg) =
    D_pulg <= 0.164 ? [pulg_a_mm3(5/16),   pulg_a_mm3(7/64)]  : // N°8
    D_pulg <= 0.190 ? [pulg_a_mm3(11/32),  pulg_a_mm3(7/64)]  : // N°10
    D_pulg <= 0.250 ? [pulg_a_mm3(7/16),   pulg_a_mm3(7/32)]  : // 1/4"
    D_pulg <= 0.3125? [pulg_a_mm3(1/2),    pulg_a_mm3(17/64)] : // 5/16"
    D_pulg <= 0.375 ? [pulg_a_mm3(9/16),   pulg_a_mm3(21/64)] : // 3/8"
    D_pulg <= 0.4375? [pulg_a_mm3(11/16),  pulg_a_mm3(3/8)]   : // 7/16"
    D_pulg <= 0.500 ? [pulg_a_mm3(3/4),    pulg_a_mm3(7/16)]  : // 1/2"
    D_pulg <= 0.5625? [pulg_a_mm3(13/16),  pulg_a_mm3(31/64)] : // 9/16"
    D_pulg <= 0.625 ? [pulg_a_mm3(15/16),  pulg_a_mm3(35/64)] : // 5/8"
    D_pulg <= 0.750 ? [pulg_a_mm3(1.125),  pulg_a_mm3(41/64)] : // 3/4"
    D_pulg <= 0.875 ? [pulg_a_mm3(1.3125), pulg_a_mm3(3/4)]   : // 7/8"
    D_pulg <= 1.000 ? [pulg_a_mm3(1.5),    pulg_a_mm3(55/64)] : // 1"
    [pulg_a_mm3(D_pulg) * 1.6, pulg_a_mm3(D_pulg) * 0.9]; // fórmula general

// -----------------------------------------------------
// Tuerca hexagonal JAM/DELGADA (ANSI B18.2.2 - Hex Jam Nut)
// Mismo ancho entre caras, espesor bastante menor
// -----------------------------------------------------
function tuerca_unc_jam(D_pulg) =
    D_pulg <= 0.164 ? [pulg_a_mm3(5/16),  pulg_a_mm3(3/32)]  :
    D_pulg <= 0.190 ? [pulg_a_mm3(11/32), pulg_a_mm3(3/32)]  :
    D_pulg <= 0.250 ? [pulg_a_mm3(7/16),  pulg_a_mm3(5/32)]  :
    D_pulg <= 0.3125? [pulg_a_mm3(1/2),   pulg_a_mm3(3/16)]  :
    D_pulg <= 0.375 ? [pulg_a_mm3(9/16),  pulg_a_mm3(7/32)]  :
    D_pulg <= 0.4375? [pulg_a_mm3(11/16), pulg_a_mm3(1/4)]   :
    D_pulg <= 0.500 ? [pulg_a_mm3(3/4),   pulg_a_mm3(5/16)]  :
    D_pulg <= 0.5625? [pulg_a_mm3(7/8),   pulg_a_mm3(21/64)] :
    D_pulg <= 0.625 ? [pulg_a_mm3(15/16), pulg_a_mm3(3/8)]   :
    D_pulg <= 0.750 ? [pulg_a_mm3(1.125), pulg_a_mm3(27/64)] :
    D_pulg <= 0.875 ? [pulg_a_mm3(1.3125),pulg_a_mm3(31/64)] :
    D_pulg <= 1.000 ? [pulg_a_mm3(1.5),   pulg_a_mm3(35/64)] :
    [pulg_a_mm3(D_pulg) * 1.6, pulg_a_mm3(D_pulg) * 0.5];

// -----------------------------------------------------
// Tuerca AUTOBLOCANTE con inserto de nylon (Nylon Insert
// Lock Nut, ANSI B18.16.6). Valores de REFERENCIA -
// verificar hoja técnica si es crítico.
// -----------------------------------------------------
function tuerca_unc_nylon(D_pulg) =
    D_pulg <= 0.190 ? [pulg_a_mm3(11/32), pulg_a_mm3(5/32)]  :
    D_pulg <= 0.250 ? [pulg_a_mm3(7/16),  pulg_a_mm3(7/32)]  :
    D_pulg <= 0.3125? [pulg_a_mm3(1/2),   pulg_a_mm3(1/4)]   :
    D_pulg <= 0.375 ? [pulg_a_mm3(9/16),  pulg_a_mm3(19/64)] :
    D_pulg <= 0.4375? [pulg_a_mm3(11/16), pulg_a_mm3(3/8)]   :
    D_pulg <= 0.500 ? [pulg_a_mm3(3/4),   pulg_a_mm3(29/64)] :
    D_pulg <= 0.625 ? [pulg_a_mm3(15/16), pulg_a_mm3(35/64)] :
    D_pulg <= 0.750 ? [pulg_a_mm3(1.125), pulg_a_mm3(43/64)] :
    [pulg_a_mm3(D_pulg) * 1.6, pulg_a_mm3(D_pulg) * 1.4];

// -----------------------------------------------------
// Tuerca CON BRIDA (Hex Flange Nut, ANSI/ASME B18.2.2)
// [ancho_entre_caras, espesor, diametro_brida]
// -----------------------------------------------------
function tuerca_unc_brida(D_pulg) =
    D_pulg <= 0.190 ? [pulg_a_mm3(11/32), pulg_a_mm3(5/32), pulg_a_mm3(0.5)]  :
    D_pulg <= 0.250 ? [pulg_a_mm3(7/16),  pulg_a_mm3(7/32), pulg_a_mm3(0.61)] :
    D_pulg <= 0.3125? [pulg_a_mm3(1/2),   pulg_a_mm3(9/32), pulg_a_mm3(0.70)] :
    D_pulg <= 0.375 ? [pulg_a_mm3(9/16),  pulg_a_mm3(5/16), pulg_a_mm3(0.80)] :
    D_pulg <= 0.500 ? [pulg_a_mm3(3/4),   pulg_a_mm3(29/64),pulg_a_mm3(1.00)] :
    [pulg_a_mm3(D_pulg) * 1.6, pulg_a_mm3(D_pulg) * 1.0, pulg_a_mm3(D_pulg) * 2.2];

// -----------------------------------------------------
// FUNCIÓN SELECTORA GENERAL
// tipo: "normal" | "jam" | "nylon" | "brida"
// serie: "UNC" | "UNF" (informativo, no afecta dimensiones)
// -----------------------------------------------------
function tuerca_unc(D_pulg, tipo = "normal", serie = "UNC") =
    tipo == "normal" ? [tuerca_unc_normal(D_pulg)[0], tuerca_unc_normal(D_pulg)[1], 0] :
    tipo == "jam"    ? [tuerca_unc_jam(D_pulg)[0],    tuerca_unc_jam(D_pulg)[1],    0] :
    tipo == "nylon"  ? [tuerca_unc_nylon(D_pulg)[0],  tuerca_unc_nylon(D_pulg)[1],  0] :
    tipo == "brida"  ? tuerca_unc_brida(D_pulg) :
    [tuerca_unc_normal(D_pulg)[0], tuerca_unc_normal(D_pulg)[1], 0];

// =====================================================
// MÓDULO: BOLSILLO HEXAGONAL PARA TUERCA UNC/UNF
// =====================================================
module bolsillo_tuerca_unc(
    diametro_rosca_pulg,
    tipo = "normal",
    profundidad_bolsillo = -1,   // -1 = usar espesor estándar de la norma
    holgura = 0.3,
    holgura_altura = 0.2
) {
    datos = tuerca_unc(diametro_rosca_pulg, tipo);
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
module agujero_pasante_tuerca_unc(
    diametro_rosca_pulg,
    profundidad,
    profundidad_bolsillo = 0,
    holgura = 0.5,
    profundidad_abs = true
) {
    diametro_rosca_mm = pulg_a_mm3(diametro_rosca_pulg);

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
module agujero_con_tuerca_unc(
    diametro_rosca_pulg,
    profundidad_pieza,             // OBLIGATORIO: espesor real de la pieza
    tipo = "normal",                 // "normal" | "jam" | "nylon" | "brida"
    serie = "UNC",                   // "UNC" | "UNF" (informativo)
    profundidad_bolsillo = -1,       // -1 = usar espesor estándar de la tabla
    holgura_tuerca = 0.3,
    holgura_pasante = 0.5,
    holgura_altura = 0.2,
    margen_corte = 0.5,               // sobresalto para evitar z-fighting
    profundidad_abs = true
) {
    datos = tuerca_unc(diametro_rosca_pulg, tipo);
    espesor_estandar = datos[1];

    bolsillo_real = profundidad_bolsillo < 0 ? espesor_estandar : profundidad_bolsillo;

    bolsillo_tuerca_unc(
        diametro_rosca_pulg = diametro_rosca_pulg,
        tipo = tipo,
        profundidad_bolsillo = bolsillo_real,
        holgura = holgura_tuerca,
        holgura_altura = holgura_altura
    );

    agujero_pasante_tuerca_unc(
        diametro_rosca_pulg = diametro_rosca_pulg,
        profundidad = profundidad_pieza + margen_corte,
        profundidad_bolsillo = bolsillo_real,
        holgura = holgura_pasante,
        profundidad_abs = profundidad_abs
    );
}

// Utilidades
function ancho_caras_tuerca_unc(D_pulg, tipo = "normal") = tuerca_unc(D_pulg, tipo)[0];
function espesor_tuerca_unc(D_pulg, tipo = "normal") = tuerca_unc(D_pulg, tipo)[1];

// =====================================================
// EJEMPLOS CON CASOS CONCRETOS - tuerca_unc(D_pulg, tipo)
// =====================================================
espesor_pieza = 12;
echo("1/4 normal:", tuerca_unc(0.25, "normal"));
translate([-60, 0, 0])
    agujero_con_tuerca_unc(0.25, profundidad_pieza = 12, tipo="normal");

echo("1/4 jam:", tuerca_unc(0.25, "jam"));
translate([-15, 0, 0])
    agujero_con_tuerca_unc(0.25, profundidad_pieza = 12, tipo="jam");

echo("1/4 nylon:", tuerca_unc(0.25, "nylon"));
translate([30, 0, 0])
    agujero_con_tuerca_unc(0.25, profundidad_pieza = 12, tipo="nylon");

echo("1/4 brida:", tuerca_unc(0.25, "brida"));
translate([75, 0, 0])
    agujero_con_tuerca_unc(0.25, profundidad_pieza = 12, tipo="brida");