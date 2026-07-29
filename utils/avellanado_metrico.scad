// =====================================================
// CALCULADORA SIMPLIFICADA DE AVELLANADO
// Para tornillos de madera - Versión cilindro recto
// =====================================================

// Función que calcula el diámetro de cabeza y altura 
// según el diámetro de la rosca (D) en mm
function cabeza_tornillo(D) = 
    D <= 3 ? [5.6, 1.65] :    // [DK, K] para M3
    D <= 4 ? [7.5, 2.2] :     // M4
    D <= 5 ? [9.2, 2.5] :     // M5
    D <= 6 ? [11.0, 3.0] :    // M6
    D <= 8 ? [14.5, 4.0] :    // M8
    D <= 10 ? [18.0, 5.0] :   // M10
    D <= 12 ? [22.0, 6.0] :   // M12
    D <= 14 ? [26.0, 7.0] :   // M14
    D <= 16 ? [30.0, 8.0] :   // M16
    [D * 1.8, D * 0.5];       // Fórmula general

// =====================================================
// MÓDULO SIMPLIFICADO - CILINDRO RECTO
// =====================================================
module avellanado_cilindrico(
    diametro_rosca,          // Diámetro del tornillo en mm
    profundidad_avellano,    // Profundidad del avellanado en mm
    holgura = 0.3            // Holgura para el diámetro
) {
    // Obtener dimensiones de la cabeza
    datos = cabeza_tornillo(diametro_rosca);
    diametro_cabeza = datos[0];
    
    // Crear el cilindro del avellanado
    translate([0, 0, 0]) 
        cylinder(h = profundidad_avellano, 
                 r = (diametro_cabeza/2) + holgura);
}

// =====================================================
// MÓDULO PARA AGUJERO PASANTE (solo diámetro)
// =====================================================
module agujero_pasante(
    diametro_rosca,          // Diámetro del tornillo en mm
    profundidad,       // Profundidad total del agujero (grosor de la pieza)
    profundidad_avellano=0,// suma del hueco de avellanado
    holgura = 0.5,            // Holgura para el diámetro
    profundidad_abs=true
) {
  if(profundidad_abs)
   translate([0, 0, profundidad_avellano]) 
        cylinder(h = profundidad -profundidad_avellano , 
                 r = (diametro_rosca/2) + holgura);
  
   else
    // Crear agujero cilíndrico pasante
    translate([0, 0, profundidad_avellano]) 
        cylinder(h = profundidad, 
                 r = (diametro_rosca/2) + holgura);
  
}

// =====================================================
// MÓDULO COMBINADO - AVELLANADO + AGUJERO PASANTE
// =====================================================
module agujero_con_avellanado(
    diametro_rosca,          // Diámetro del tornillo en mm
    profundidad_avellano,    // Profundidad del avellanado en mm
    profundidad_pieza,       // Grosor total de la pieza en mm
    holgura_avellano = 0.3,  // Holgura para el avellanado
    holgura_pasante = 0.5,    // Holgura para el agujero pasante
    profundidad_abs=true,
) {
    // Avellanado (cilindro recto)
   avellanado_cilindrico(
        diametro_rosca = diametro_rosca,
        profundidad_avellano = profundidad_avellano,
        holgura = holgura_avellano
    );
  
    // Agujero pasante (desde el fondo del avellanado hasta el final)
        agujero_pasante(
            diametro_rosca = diametro_rosca,
            profundidad = profundidad_pieza ,
            profundidad_avellano= profundidad_avellano,
            holgura = holgura_pasante,
            profundidad_abs=profundidad_abs
        );
}


// =====================================================
// FUNCIONES DE UTILIDAD
// =====================================================

// Función para obtener solo el diámetro de cabeza
function diametro_cabeza(D) = cabeza_tornillo(D)[0];

// Función para obtener solo la altura de cabeza
function altura_cabeza(D) = cabeza_tornillo(D)[1];

// =====================================================
// VISUALIZACIÓN DE EJEMPLOS
// =====================================================
translate([-20, 0, 0])
rotate([0.,180,0]){
agujero_con_avellanado(8, 4.5, 9.5);
 }
agujero_con_avellanado(8, 4.5, 9.5);

translate([20, 0, 0])
agujero_con_avellanado(8, 4.5, 9.5,profundidad_abs=false);
