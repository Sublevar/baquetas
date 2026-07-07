// =====================================================
// CALCULADORA DE AVELLANADO - TORNILLOS MÉTRICOS
// Para tornillos de madera - Versión cilindro recto
// DEMO 3D: placa real con los cortes aplicados
// =====================================================

// Función que calcula el diámetro de cabeza y altura
// según el diámetro de la rosca (D) en mm
function cabeza_tornillo(D) =
    D <= 3  ? [5.6,  1.65] :  // M3
    D <= 4  ? [7.5,  2.2]  :  // M4
    D <= 5  ? [9.2,  2.5]  :  // M5
    D <= 6  ? [11.0, 3.0]  :  // M6
    D <= 8  ? [14.5, 4.0]  :  // M8
    D <= 10 ? [18.0, 5.0]  :  // M10
    D <= 12 ? [22.0, 6.0]  :  // M12
    D <= 14 ? [26.0, 7.0]  :  // M14
    D <= 16 ? [30.0, 8.0]  :  // M16
    [D * 1.8, D * 0.5];       // fórmula general

// =====================================================
// MÓDULO SIMPLIFICADO - CILINDRO RECTO
// =====================================================
module avellanado_cilindrico(
    diametro_rosca,
    profundidad_avellano,
    holgura = 0.3
) {
    datos = cabeza_tornillo(diametro_rosca);
    diametro_cabeza = datos[0];

    translate([0, 0, 0])
        cylinder(h = profundidad_avellano,
                 r = (diametro_cabeza/2) + holgura);
}

// =====================================================
// MÓDULO PARA AGUJERO PASANTE (solo diámetro)
// =====================================================
module agujero_pasante(
    diametro_rosca,
    profundidad,
    profundidad_avellano = 0,
    holgura = 0.5,
    profundidad_abs = true
) {
    if (profundidad_abs)
        translate([0, 0, profundidad_avellano])
            cylinder(h = profundidad - profundidad_avellano,
                     r = (diametro_rosca/2) + holgura);
    else
        translate([0, 0, profundidad_avellano])
            cylinder(h = profundidad,
                     r = (diametro_rosca/2) + holgura);
}

// =====================================================
// MÓDULO COMBINADO - AVELLANADO + AGUJERO PASANTE
// =====================================================
module agujero_con_avellanado(
    diametro_rosca,
    profundidad_avellano,
    profundidad_pieza,
    holgura_avellano = 0.3,
    holgura_pasante = 0.5,
    profundidad_abs = true
) {
    avellanado_cilindrico(
        diametro_rosca = diametro_rosca,
        profundidad_avellano = profundidad_avellano,
        holgura = holgura_avellano
    );

    agujero_pasante(
        diametro_rosca = diametro_rosca,
        profundidad = profundidad_pieza,
        profundidad_avellano = profundidad_avellano,
        holgura = holgura_pasante,
        profundidad_abs = profundidad_abs
    );
}

// Funciones de utilidad
function diametro_cabeza(D) = cabeza_tornillo(D)[0];
function altura_cabeza(D) = cabeza_tornillo(D)[1];

// =====================================================
// DEMO 3D: placa con 3 avellanados de distinto diámetro
// margen de corte para evitar z-fighting en el booleano
// =====================================================
margen_corte = 0.5;
espesor_placa = 12;       // mm - grosor de la placa demo
ancho_placa   = 100;
largo_placa   = 40;

module placa_demo_metrica() {
    difference() {
        // Placa base
        translate([-10, -largo_placa/2, 0])
            cube([ancho_placa, largo_placa, espesor_placa]);

        // Avellanado M6, entra por la cara superior (z = espesor_placa)
        translate([10, 0, espesor_placa])
            rotate([0, 180, 0])
                agujero_con_avellanado(
                    diametro_rosca = 6,
                    profundidad_avellano = 3.5,
                    profundidad_pieza = espesor_placa + margen_corte
                );

        // Avellanado M8, entra por la cara superior
        translate([40, 0, espesor_placa])
            rotate([0, 180, 0])
                agujero_con_avellanado(
                    diametro_rosca = 8,
                    profundidad_avellano = 4.5,
                    profundidad_pieza = espesor_placa + margen_corte
                );

        // Avellanado M10, entra por la cara inferior (profundidad_abs=false)
        // demuestra el otro modo de medir la profundidad
        translate([70, 0, 0])
            agujero_con_avellanado(
                diametro_rosca = 10,
                profundidad_avellano = 5.0,
                profundidad_pieza = espesor_placa + margen_corte,
                profundidad_abs = false
            );
    }
}

placa_demo_metrica();
