/* ============================================================
   CONFIG COMUN
   Un solo lugar para los valores compartidos por todas las
   piezas. Se carga con:  include <config.scad>
   (include, no use: use no exporta variables)

   Para otra impresora / pico: elegir el perfil (abajo) y regenerar
   todo, o pisarlo desde la linea de comandos:
       openscad -D '_perfil="pico08"' ...
   ./build.sh pico08 lo hace por vos.
   ============================================================ */

/* ---------- PERFILES DE IMPRESION ----------
   Cada perfil fija los valores que dependen de la boquilla.
   Para agregar uno: una fila nueva en _perfiles.
     pico04: boquilla 0.4 o menor, holgura radial 0.5 mm
     pico08: boquilla 0.8 (Bambu A1, extra draft custom), holgura 1.5 mm
   Columnas: [nombre, holgura radial (mm)]                              */
_perfil = "pico04";    // "pico04" | "pico08"

_perfiles = [
    ["pico04", 0.5],
    ["pico08", 1.5],
];

_i_perfil = [for (i = [0 : len(_perfiles) - 1]) if (_perfiles[i][0] == _perfil) i];
assert(len(_i_perfil) == 1,
       str("config.scad: perfil desconocido '", _perfil, "' (ver _perfiles)"));

// Baqueta / eje
_diametro        = 24;     // diametro interior del eje (mm)
_holgura         = _perfiles[_i_perfil[0]][1];   // holgura radial: sale del perfil
_poly_n          = 16;     // resolucion de circulos

// Tornillo de presion / tuerca
_familia_tuerca  = "UNC";       // "UNC" | "UNF" | "metrica" | "whitworth"
_subtipo_tuerca  = "normal";    // "normal" | "delgada" | "autoblocante" | "brida"
_medida_tornillo = 0.1875;      // pulgadas para UNC/UNF/whitworth; mm para metrica

// Grosor de material para alojar tornillo (profundidad_pieza)
_profundidad     = 20;

// Pared minima entre dos huecos de baqueta que se acercan (mm).
// Con pico 0.8 conviene >= 2 perimetros (1.6 mm); 3 queda comodo.
_pared_min       = 3;
