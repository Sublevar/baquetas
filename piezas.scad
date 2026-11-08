include <config.scad>
use <juntas.scad>
use <hirth.scad>
use <patas.scad>
use <apoyos.scad>
use <diagonales.scad>
use <tripodes.scad>
use <sin_tornillo.scad>
use <elementos_flex.scad>
use <muebles.scad>

/* ============================================================
   SELECTOR DE PIEZAS
   Una pieza fisica por STL. Se elige con -D:

     openscad -D 'pieza="junta_doble"' -o junta_doble.stl piezas.scad

   build.sh recorre toda la lista y ordena los STL por tipo.
   Para agregar una pieza: una linea aca y una en build.sh.
   ============================================================ */
pieza = "ninguna";

// --- juntas ---
if      (pieza == "junta_doble")             junta_doble();
else if (pieza == "junta_doble_linea")       junta_doble(rot_a = 0, rot_b = 0);
else if (pieza == "junta_array_gradual")     junta_array(modo = "gradual");
else if (pieza == "junta_array_extremos")    junta_array(modo = "extremos");
else if (pieza == "junta_array_degrade")     junta_array(modo = "degrade");
else if (pieza == "junta_array_solo_extremos") junta_array(modo = "solo_extremos");
else if (pieza == "junta_T")                 junta_T();
else if (pieza == "junta_angulo")            junta_angulo();
else if (pieza == "union_lineal")            union_lineal();
else if (pieza == "terminal")                terminal();

// --- hirth (cada mitad en su propio marco, dientes hacia arriba) ---
else if (pieza == "hirth_A")                 junta_hirth(vista = "A");
else if (pieza == "hirth_B")                 junta_hirth(vista = "B");
else if (pieza == "hirth_cil_A")             junta_hirth(modo = "cilindros", vista = "A");
else if (pieza == "hirth_cil_B")             junta_hirth(modo = "cilindros", vista = "B");
else if (pieza == "hirth_cil90_A")           junta_hirth(modo = "cilindros_90", vista = "A");
else if (pieza == "hirth_cil90_B")           junta_hirth(modo = "cilindros_90", vista = "B");

// --- patas ---
else if (pieza == "pata_base")               pata_base();
else if (pieza == "rotula_vastago")          pata_rotula(vista = "vastago");
else if (pieza == "rotula_copa")             pata_rotula(vista = "copa");

// --- apoyos ---
else if (pieza == "pared_perpendicular")     acople_pared();
else if (pieza == "pared_paralelo")          acople_pared(modo = "paralelo", largo = 70);
else if (pieza == "estante_un_brazo")        apoyo_estante();
else if (pieza == "estante_esquinero")       apoyo_estante(brazos = [0, 90]);


// --- diagonales y brazos (angulo desde el poste; ver diagonales.scad) ---
else if (pieza == "diagonal_45")             acople_diagonal(angulo = 45);
else if (pieza == "diagonal_45_doble")       acople_diagonal(angulo = 45, azimuts = [0, 180]);
else if (pieza == "diagonal_135")            acople_diagonal(angulo = 135);
else if (pieza == "brazo")                   acople_brazo();
else if (pieza == "brazo_esquinero")         acople_brazo(azimuts = [0, 90]);

// --- tripodes ---
else if (pieza == "tripode_3")               pie_tripode(patas = 3, apertura = 25);
else if (pieza == "tripode_4")               pie_tripode(patas = 4, apertura = 20);
else if (pieza == "punta_pata_25")           punta_pata(apertura = 25);
else if (pieza == "punta_pata_20")           punta_pata(apertura = 20);


// --- sin tornillo, para palos de 22 a 24 mm (ver sin_tornillo.scad); salen de pie, boca arriba ---
else if (pieza == "flexible_acople")         rotate([0, -90, 0]) acople_flexible();
else if (pieza == "flexible_collar")         rotate([0, -90, 0]) collar_flexible();
else if (pieza == "flexible_tapon")          rotate([0, -90, 0]) tapon_flexible();
else if (pieza == "flexible_cuna")           cuna_ajuste();
else if (pieza == "flexible_calibre")        calibre_palo();
else if (pieza == "flexible_prueba")         prueba_flexible();


// --- elementos sin tornillo (ver elementos_flex.scad; PRUEBAS pendientes alli) ---
else if (pieza == "elem_manguito_tope")      manguito_tope();
else if (pieza == "elem_hub_cruce")          hub_cruce();
else if (pieza == "elem_bandeja")            bandeja();
else if (pieza == "elem_canasto")            canasto();
else if (pieza == "elem_brazo_estante")      brazo_estante();
else if (pieza == "elem_multi_gancho")       multi_gancho();
else if (pieza == "elem_base")               base_flex();
else if (pieza == "elem_tapa_plato")         tapa_plato();

// --- muebles con tornillo de presion (ver muebles.scad) ---
else if (pieza == "mueble_esquinero_tabla")  rotate([180, 0, 0]) esquinero_tabla();   // placa contra la cama
else if (pieza == "mueble_guia_cajon")       guia_cajon();
else if (pieza == "mueble_bolsillo_panel")   bolsillo_panel();

else echo(str("piezas.scad: pieza desconocida o sin elegir -> '", pieza, "'"));
