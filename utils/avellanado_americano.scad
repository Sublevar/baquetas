// =====================================================
// CALCULADORA DE AVELLANADO - TORNILLOS AMERICANOS
// (Flat Head Wood Screws, numeración ANSI/ASME B18.6.1)
// El diámetro de rosca se ingresa como N° de calibre
// USA (Wood Screw Gauge) o en pulgadas decimales
// Versión cilindro recto - DEMO 3D
// =====================================================
// NOTA: los tornillos de madera americanos se especifican
// por NÚMERO DE CALIBRE (#4, #6, #8, #10, #12) y no por
// diámetro directo como en métrico. A partir de 1/4" ya
// se especifican en pulgadas normales.
// Valores de cabeza (DK, K) tomados de tablas de referencia
// de flat head wood screws - verificar contra fabricante
// si es para producción crítica.
// =====================================================

PULGADA_AM = 25.4;
function pulg_a_mm_am(p) = p * PULGADA_AM;

// -----------------------------------------------------
// Diámetro de vástago (shank) según N° de calibre USA
// (en pulgadas decimales)
// -----------------------------------------------------
function diametro_calibre(numero) =
    numero == 2  ? 0.086 :
    numero == 3  ? 0.099 :
    numero == 4  ? 0.112 :
    numero == 5  ? 0.125 :
    numero == 6  ? 0.138 :
    numero == 7  ? 0.151 :
    numero == 8  ? 0.164 :
    numero == 9  ? 0.177 :
    numero == 10 ? 0.190 :
    numero == 12 ? 0.216 :
    numero == 14 ? 0.242 :
    0.190; // default: N°10

// -----------------------------------------------------
// Función que calcula [DK, K] en mm según el diámetro
// de rosca en PULGADAS decimales (shank diameter)
// Acepta tanto el resultado de diametro_calibre() como
// una pulgada normal (1/4", 5/16", 3/8") directamente
// -----------------------------------------------------
function cabeza_tornillo_americano(D_pulg) =
    D_pulg <= 0.086 ? [pulg_a_mm_am(0.216), pulg_a_mm_am(0.062)] : // N°2
    D_pulg <= 0.099 ? [pulg_a_mm_am(0.242), pulg_a_mm_am(0.070)] : // N°3
    D_pulg <= 0.112 ? [pulg_a_mm_am(0.268), pulg_a_mm_am(0.079)] : // N°4
    D_pulg <= 0.125 ? [pulg_a_mm_am(0.295), pulg_a_mm_am(0.088)] : // N°5
    D_pulg <= 0.138 ? [pulg_a_mm_am(0.320), pulg_a_mm_am(0.096)] : // N°6
    D_pulg <= 0.151 ? [pulg_a_mm_am(0.345), pulg_a_mm_am(0.104)] : // N°7
    D_pulg <= 0.164 ? [pulg_a_mm_am(0.371), pulg_a_mm_am(0.112)] : // N°8
    D_pulg <= 0.177 ? [pulg_a_mm_am(0.397), pulg_a_mm_am(0.120)] : // N°9
    D_pulg <= 0.190 ? [pulg_a_mm_am(0.423), pulg_a_mm_am(0.128)] : // N°10
    D_pulg <= 0.216 ? [pulg_a_mm_am(0.475), pulg_a_mm_am(0.144)] : // N°12
    D_pulg <= 0.242 ? [pulg_a_mm_am(0.507), pulg_a_mm_am(0.153)] : // N°14
    D_pulg <= 0.250 ? [pulg_a_mm_am(0.530), pulg_a_mm_am(0.160)] : // 1/4"
    D_pulg <= 0.3125? [pulg_a_mm_am(0.650), pulg_a_mm_am(0.195)] : // 5/16"
    D_pulg <= 0.375 ? [pulg_a_mm_am(0.770), pulg_a_mm_am(0.230)] : // 3/8"
    [pulg_a_mm_am(D_pulg) * 1.9, pulg_a_mm_am(D_pulg) * 0.55];     // fórmula general

// =====================================================
// MÓDULO SIMPLIFICADO - CILINDRO RECTO
// diametro_rosca_pulg: diámetro de vástago en pulgadas
// (usar diametro_calibre(N) para tornillos por número)
// =====================================================
module avellanado_cilindrico_americano(
    diametro_rosca_pulg,
    profundidad_avellano,
    holgura = 0.3,
    altura_extra = 0,        // Altura adicional del avellanado en mm
    offset_z = 0             // Desplazamiento vertical en mm (default 0)
) {
    datos = cabeza_tornillo_americano(diametro_rosca_pulg);
    diametro_cabeza = datos[0];
    altura_total = profundidad_avellano + altura_extra;

    translate([0, 0, offset_z])
        cylinder(h = altura_total,
                 r = (diametro_cabeza/2) + holgura);
}

// =====================================================
// MÓDULO PARA AGUJERO PASANTE (solo diámetro)
// =====================================================
module agujero_pasante_americano(
    diametro_rosca_pulg,
    profundidad,
    profundidad_avellano = 0,
    holgura = 0.5,
    profundidad_abs = true,
    altura_extra = 0,        // Altura adicional del agujero en mm
    offset_z = 0             // Desplazamiento vertical en mm (default 0)
) {
    diametro_rosca_mm = pulg_a_mm_am(diametro_rosca_pulg);

    if (profundidad_abs)
        translate([0, 0, profundidad_avellano + offset_z])
            cylinder(h = profundidad - profundidad_avellano + altura_extra,
                     r = (diametro_rosca_mm/2) + holgura);
    else
        translate([0, 0, profundidad_avellano + offset_z])
            cylinder(h = profundidad + altura_extra,
                     r = (diametro_rosca_mm/2) + holgura);
}

// =====================================================
// MÓDULO COMBINADO - AVELLANADO + AGUJERO PASANTE
// =====================================================
module agujero_con_avellanado_americano(
    diametro_rosca_pulg,
    profundidad_avellano,
    profundidad_pieza,
    holgura_avellano = 0.3,
    holgura_pasante = 0.5,
    profundidad_abs = true,
    altura_extra = 0,        // Altura adicional del avellanado en mm
    offset_z = 0,            // Desplazamiento vertical en mm (default 0)
    altura_extra_pasante = 0,// Altura adicional del agujero en mm
    offset_z_pasante = 0     // Desplazamiento vertical del agujero en mm (default 0)
) {
    avellanado_cilindrico_americano(
        diametro_rosca_pulg = diametro_rosca_pulg,
        profundidad_avellano = profundidad_avellano,
        holgura = holgura_avellano,
        altura_extra = altura_extra,
        offset_z = offset_z
    );

    agujero_pasante_americano(
        diametro_rosca_pulg = diametro_rosca_pulg,
        profundidad = profundidad_pieza,
        profundidad_avellano = profundidad_avellano,
        holgura = holgura_pasante,
        profundidad_abs = profundidad_abs,
        altura_extra = altura_extra_pasante,
        offset_z = offset_z_pasante
    );
}

// Funciones de utilidad
function diametro_cabeza_americano(D_pulg) = cabeza_tornillo_americano(D_pulg)[0];
function altura_cabeza_americano(D_pulg) = cabeza_tornillo_americano(D_pulg)[1];

// =====================================================
// DEMO 3D: placa con 3 avellanados de distinto calibre
// margen de corte para evitar z-fighting en el booleano
// =====================================================
margen_corte_am = 0.5;
espesor_placa_am = 12;   // mm - grosor de la placa demo
ancho_placa_am   = 100;
largo_placa_am   = 40;

module placa_demo_americana() {
    difference() {
        // Placa base
        translate([-10, -largo_placa_am/2, 0])
            cube([ancho_placa_am, largo_placa_am, espesor_placa_am]);

        // Tornillo N°8, entra por la cara superior
        translate([10, 0, espesor_placa_am])
            rotate([0, 180, 0])
                agujero_con_avellanado_americano(
                    diametro_rosca_pulg = diametro_calibre(8),
                    profundidad_avellano = 3.0,
                    profundidad_pieza = espesor_placa_am + margen_corte_am
                );

        // Tornillo N°10, entra por la cara superior
        translate([40, 0, espesor_placa_am])
            rotate([0, 180, 0])
                agujero_con_avellanado_americano(
                    diametro_rosca_pulg = diametro_calibre(10),
                    profundidad_avellano = 3.5,
                    profundidad_pieza = espesor_placa_am + margen_corte_am
                );

        // Tornillo 1/4", entra por la cara inferior
        // (demuestra profundidad_abs = false)
        translate([70, 0, 0])
            agujero_con_avellanado_americano(
                diametro_rosca_pulg = 0.25,
                profundidad_avellano = 4.0,
                profundidad_pieza = espesor_placa_am + margen_corte_am,
                profundidad_abs = false
            );
    }
}

placa_demo_americana();
