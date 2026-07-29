// =====================================================
// CALCULADORA DE AVELLANADO - TORNILLOS WHITWORTH (BSW)
// El diámetro de rosca se ingresa en PULGADAS (decimal)
// Ej: 1/4" = 0.25 , 3/8" = 0.375 , 1/2" = 0.5
// =====================================================

PULGADA = 25.4; // mm por pulgada

// Convierte pulgadas a mm
function pulg_a_mm(p) = p * PULGADA;

// Tabla de diámetros nominales Whitworth más comunes (en pulgadas)
// junto a su equivalente en mm, para referencia:
// 1/8"  = 3.175 mm      5/16" = 7.938 mm      5/8" = 15.875 mm
// 3/16" = 4.763 mm      3/8"  = 9.525 mm      3/4" = 19.050 mm
// 1/4"  = 6.350 mm      7/16" = 11.113 mm     7/8" = 22.225 mm
// 5/16" = 7.938 mm      1/2"  = 12.700 mm     1"   = 25.400 mm

// Función que calcula [DK, K] en mm según el diámetro de rosca
// D_pulg: diámetro nominal en pulgadas (ej: 0.25 para 1/4")
// NOTA: al no existir una norma DIN/ISO de cabeza avellanada para
// Whitworth, se usa la regla práctica DK≈2*D, K≈0.6*D.
// Ajustar si contás con la tabla real del fabricante.
function cabeza_tornillo_whitworth(D_pulg) =
    let(D = pulg_a_mm(D_pulg))
    [D * 2.0, D * 0.6];

// =====================================================
// MÓDULO: AVELLANADO PARA TORNILLO WHITWORTH
// =====================================================
module avellanado_cilindrico_whitworth(
    diametro_rosca_pulg,      // Diámetro del tornillo en PULGADAS
    profundidad_avellano,     // Profundidad del avellanado en mm
    holgura = 0.3             // Holgura para el diámetro en mm
) {
    datos = cabeza_tornillo_whitworth(diametro_rosca_pulg);
    diametro_cabeza = datos[0];

    translate([0, 0, 0])
        cylinder(h = profundidad_avellano,
                 r = (diametro_cabeza/2) + holgura);
}

// =====================================================
// MÓDULO: AGUJERO PASANTE PARA TORNILLO WHITWORTH
// =====================================================
module agujero_pasante_whitworth(
    diametro_rosca_pulg,       // Diámetro del tornillo en PULGADAS
    profundidad,                // Profundidad total del agujero
    profundidad_avellano = 0,   // Suma del hueco de avellanado
    holgura = 0.5,               // Holgura para el diámetro en mm
    profundidad_abs = true
) {
    diametro_rosca_mm = pulg_a_mm(diametro_rosca_pulg);

    if (profundidad_abs)
        translate([0, 0, profundidad_avellano])
            cylinder(h = profundidad - profundidad_avellano,
                     r = (diametro_rosca_mm/2) + holgura);
    else
        translate([0, 0, profundidad_avellano])
            cylinder(h = profundidad,
                     r = (diametro_rosca_mm/2) + holgura);
}

// =====================================================
// MÓDULO COMBINADO - AVELLANADO + AGUJERO (WHITWORTH)
// =====================================================
module agujero_con_avellanado_whitworth(
    diametro_rosca_pulg,        // Diámetro del tornillo en PULGADAS
    profundidad_avellano,       // Profundidad del avellanado en mm
    profundidad_pieza,          // Grosor total de la pieza en mm
    holgura_avellano = 0.3,
    holgura_pasante = 0.5,
    profundidad_abs = true
) {
    avellanado_cilindrico_whitworth(
        diametro_rosca_pulg = diametro_rosca_pulg,
        profundidad_avellano = profundidad_avellano,
        holgura = holgura_avellano
    );

    agujero_pasante_whitworth(
        diametro_rosca_pulg = diametro_rosca_pulg,
        profundidad = profundidad_pieza,
        profundidad_avellano = profundidad_avellano,
        holgura = holgura_pasante,
        profundidad_abs = profundidad_abs
    );
}

// Funciones de utilidad
function diametro_cabeza_whitworth(D_pulg) = cabeza_tornillo_whitworth(D_pulg)[0];
function altura_cabeza_whitworth(D_pulg) = cabeza_tornillo_whitworth(D_pulg)[1];

// =====================================================
// EJEMPLO: tornillo Whitworth 5/16" (0.3125"), avellanado
// de 4.5mm de profundidad, pieza de 9.5mm de espesor
// =====================================================
agujero_con_avellanado_whitworth(5/16, 4.5, 9.5);
