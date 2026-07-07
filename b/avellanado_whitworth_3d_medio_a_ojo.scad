// =====================================================
// CALCULADORA DE AVELLANADO - TORNILLOS WHITWORTH (BSW)
// El diámetro de rosca se ingresa en PULGADAS (decimal)
// Ej: 1/4" = 0.25 , 3/8" = 0.375 , 1/2" = 0.5
// Versión cilindro recto - DEMO 3D
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
// DEMO 3D: placa con 3 avellanados de distinto diámetro
// margen de corte para evitar z-fighting en el booleano
// =====================================================
margen_corte_wh = 0.5;
espesor_placa_wh = 12;   // mm - grosor de la placa demo
ancho_placa_wh   = 100;
largo_placa_wh   = 40;

module placa_demo_whitworth() {
    difference() {
        // Placa base
        translate([-10, -largo_placa_wh/2, 0])
            cube([ancho_placa_wh, largo_placa_wh, espesor_placa_wh]);

        // Tornillo Whitworth 3/16", entra por la cara superior
        translate([10, 0, espesor_placa_wh])
            rotate([0, 180, 0])
                agujero_con_avellanado_whitworth(
                    diametro_rosca_pulg = 3/16,
                    profundidad_avellano = 3.0,
                    profundidad_pieza = espesor_placa_wh + margen_corte_wh
                );

        // Tornillo Whitworth 1/4", entra por la cara superior
        translate([40, 0, espesor_placa_wh])
            rotate([0, 180, 0])
                agujero_con_avellanado_whitworth(
                    diametro_rosca_pulg = 1/4,
                    profundidad_avellano = 4.0,
                    profundidad_pieza = espesor_placa_wh + margen_corte_wh
                );

        // Tornillo Whitworth 5/16", entra por la cara inferior
        // (demuestra profundidad_abs = false)
        translate([70, 0, 0])
            agujero_con_avellanado_whitworth(
                diametro_rosca_pulg = 5/16,
                profundidad_avellano = 4.5,
                profundidad_pieza = espesor_placa_wh + margen_corte_wh,
                profundidad_abs = false
            );
    }
}

placa_demo_whitworth();
