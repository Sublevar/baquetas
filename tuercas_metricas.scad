// =====================================================
// CALCULADORA - TUERCAS MÉTRICAS (varios tipos)
// DIN 934 (normal) / DIN 936 (delgada) /
// DIN 985 (autoblocante nylon) / DIN 6923 (con brida)
// El diámetro de rosca se ingresa en MILÍMETROS (M)
// =====================================================

// -----------------------------------------------------
// DIN 934 / ISO 4032 - Tuerca hexagonal NORMAL
// [ancho_entre_caras, espesor]
// -----------------------------------------------------
function tuerca_din934(D) =
    D <= 3  ? [5.5,  2.4]  :
    D <= 4  ? [7.0,  3.2]  :
    D <= 5  ? [8.0,  4.7]  :
    D <= 6  ? [10.0, 5.2]  :
    D <= 8  ? [13.0, 6.8]  :
    D <= 10 ? [16.0, 8.4]  :
    D <= 12 ? [18.0, 10.8] :
    D <= 14 ? [21.0, 12.8] :
    D <= 16 ? [24.0, 14.8] :
    D <= 18 ? [27.0, 15.8] :
    D <= 20 ? [30.0, 18.0] :
    D <= 24 ? [36.0, 21.5] :
    [D * 1.6, D * 0.9]; // fórmula general

// -----------------------------------------------------
// DIN 936 / ISO 4035 - Tuerca hexagonal DELGADA
// -----------------------------------------------------
function tuerca_din936(D) =
    D <= 3  ? [5.5,  1.8] :
    D <= 4  ? [7.0,  2.2] :
    D <= 5  ? [8.0,  2.7] :
    D <= 6  ? [10.0, 3.2] :
    D <= 8  ? [13.0, 4.0] :
    D <= 10 ? [16.0, 5.0] :
    D <= 12 ? [18.0, 6.0] :
    D <= 14 ? [21.0, 7.0] :
    D <= 16 ? [24.0, 8.0] :
    D <= 18 ? [27.0, 9.0] :
    D <= 20 ? [30.0, 10.0] :
    D <= 24 ? [36.0, 12.0] :
    [D * 1.6, D * 0.5]; // fórmula general

// -----------------------------------------------------
// DIN 985 / ISO 10511 - Tuerca AUTOBLOCANTE (nylon)
// Valores de REFERENCIA (varían según fabricante)
// -----------------------------------------------------
function tuerca_din985(D) =
    D <= 3  ? [5.5,  4.0]  :
    D <= 4  ? [7.0,  5.0]  :
    D <= 5  ? [8.0,  5.7]  :
    D <= 6  ? [10.0, 7.5]  :
    D <= 8  ? [13.0, 9.5]  :
    D <= 10 ? [16.0, 11.4] :
    D <= 12 ? [18.0, 13.9] :
    D <= 14 ? [21.0, 16.0] :
    D <= 16 ? [24.0, 16.4] :
    D <= 18 ? [27.0, 18.5] :
    D <= 20 ? [30.0, 19.5] :
    [D * 1.6, D * 1.4]; // fórmula general aproximada

// -----------------------------------------------------
// DIN 6923 - Tuerca hexagonal CON BRIDA
// [ancho_entre_caras, espesor, diametro_brida]
// -----------------------------------------------------
function tuerca_din6923(D) =
    D <= 4  ? [7.0,  5.0,  9.8]  :
    D <= 5  ? [8.0,  5.0,  11.8] :
    D <= 6  ? [10.0, 6.0,  15.8] :
    D <= 8  ? [13.0, 8.0,  19.6] :
    D <= 10 ? [16.0, 10.0, 23.8] :
    D <= 12 ? [18.0, 12.0, 27.6] :
    D <= 14 ? [21.0, 14.0, 31.4] :
    D <= 16 ? [24.0, 16.0, 34.5] :
    [D * 1.6, D * 1.0, D * 3.0]; // fórmula general

// -----------------------------------------------------
// FUNCIÓN SELECTORA GENERAL
// Devuelve siempre [ancho_caras, espesor, diametro_brida]
// (diametro_brida = 0 si el tipo no tiene brida)
// -----------------------------------------------------
function tuerca_metrica(D, tipo = "normal") =
    tipo == "normal"       ? [tuerca_din934(D)[0],  tuerca_din934(D)[1],  0] :
    tipo == "delgada"      ? [tuerca_din936(D)[0],  tuerca_din936(D)[1],  0] :
    tipo == "autoblocante" ? [tuerca_din985(D)[0],  tuerca_din985(D)[1],  0] :
    tipo == "brida"        ? tuerca_din6923(D) :
    tuerca_din934(D); // por defecto, normal

// =====================================================
// MÓDULO: BOLSILLO HEXAGONAL PARA TUERCA MÉTRICA
// profundidad_bolsillo ahora es OPCIONAL:
// si no se pasa (queda -1), se usa el espesor estándar (m)
// =====================================================
module bolsillo_tuerca_metrica(
    diametro_rosca,             // Diámetro nominal en mm (ej: 8 para M8)
    tipo = "normal",             // "normal" | "delgada" | "autoblocante" | "brida"
    profundidad_bolsillo = -1,   // -1 = usar altura estándar según norma
    holgura = 0.3,
    holgura_altura = 0.2
) {
    datos = tuerca_metrica(diametro_rosca, tipo);
    ancho_caras = datos[0];
    espesor_estandar = datos[1];

    // Si no se especificó, usar el valor estándar de la norma
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
module agujero_pasante_tuerca_metrica(
    diametro_rosca,
    profundidad,
    profundidad_bolsillo = 0,
    holgura = 0.5,
    profundidad_abs = true
) {
    if (profundidad_abs)
        translate([0, 0, profundidad_bolsillo])
            cylinder(h = profundidad - profundidad_bolsillo,
                     r = (diametro_rosca/2) + holgura);
    else
        translate([0, 0, profundidad_bolsillo])
            cylinder(h = profundidad,
                     r = (diametro_rosca/2) + holgura);
}

// =====================================================
// MÓDULO COMBINADO: TUERCA EMBUTIDA + AGUJERO PASANTE
// profundidad_bolsillo y profundidad_pieza ahora son
// OPCIONALES: si no se pasan, se calculan según la norma
// =====================================================
module agujero_con_tuerca_metrica(
    diametro_rosca,
    tipo = "normal",              // Tipo de tuerca
    profundidad_bolsillo = -1,    // -1 = usar altura estándar (m) de la norma
    profundidad_pieza = -1,       // -1 = calcular automáticamente (bolsillo + margen)
    margen_pieza = 3,              // mm extra de material debajo de la tuerca (si se autocalcula)
    holgura_tuerca = 0.3,
    holgura_pasante = 0.5,
    holgura_altura = 0.2,
    profundidad_abs = true
) {
    datos = tuerca_metrica(diametro_rosca, tipo);
    espesor_estandar = datos[1];

    // Resolver profundidad del bolsillo (default = altura estándar de norma)
    bolsillo_real = profundidad_bolsillo < 0 ? espesor_estandar : profundidad_bolsillo;

    // Resolver profundidad de la pieza (default = bolsillo + margen)
    pieza_real = profundidad_pieza < 0 ? (bolsillo_real + holgura_altura + margen_pieza) : profundidad_pieza;

    bolsillo_tuerca_metrica(
        diametro_rosca = diametro_rosca,
        tipo = tipo,
        profundidad_bolsillo = bolsillo_real,
        holgura = holgura_tuerca,
        holgura_altura = holgura_altura
    );

    agujero_pasante_tuerca_metrica(
        diametro_rosca = diametro_rosca,
        profundidad = pieza_real,
        profundidad_bolsillo = bolsillo_real,
        holgura = holgura_pasante,
        profundidad_abs = profundidad_abs
    );
}

// Utilidades
function ancho_caras_tuerca_metrica(D, tipo = "normal") = tuerca_metrica(D, tipo)[0];
function espesor_tuerca_metrica(D, tipo = "normal") = tuerca_metrica(D, tipo)[1];
function brida_tuerca_metrica(D, tipo = "brida") = tuerca_metrica(D, tipo)[2];

// =====================================================
// EJEMPLOS - ahora con defaults automáticos
// (no hace falta pasar profundidad_bolsillo ni profundidad_pieza)
// =====================================================

// M8 normal (DIN 934): usa m=6.8mm automáticamente
echo("M8 normal:", tuerca_metrica(8, "normal"));
translate([-40, 0, 0])
    agujero_con_tuerca_metrica(8, tipo="normal");
translate([-40, -30, 0])
    agujero_con_tuerca_metrica(8,profundidad_pieza = 15, tipo="normal");
translate([-40, 30, 0])
    agujero_con_tuerca_metrica(8,profundidad_pieza = 15, tipo="normal",     profundidad_abs = false);

// M8 delgada (DIN 936): usa m=4.0mm automáticamente
echo("M8 delgada:", tuerca_metrica(8, "delgada"));
translate([-15, 0, 0])
    agujero_con_tuerca_metrica(8, tipo="delgada");

// M8 autoblocante (DIN 985): usa m=9.5mm automáticamente
echo("M8 autoblocante:", tuerca_metrica(8, "autoblocante"));
translate([15, 0, 0])
    agujero_con_tuerca_metrica(8, tipo="autoblocante");

// M8 con brida (DIN 6923): usa m=8.0mm automáticamente
echo("M8 con brida:", tuerca_metrica(8, "brida"));
translate([40, 0, 0])
    agujero_con_tuerca_metrica(8, tipo="brida");

// Si igual querés forzar un valor custom, lo podés seguir pasando:
translate([0, 20, 0])
    agujero_con_tuerca_metrica(10, tipo="normal", profundidad_bolsillo = 5, profundidad_pieza = 15);