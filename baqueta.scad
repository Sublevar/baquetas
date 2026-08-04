//use <hueco_baqueta.scad>;
//
//
//difference() {
//    baqueta_solida(ancho_baqueta=60);
//    
//   translate([ -10,0, 0])
//   hueco_baqueta(cantidad_tornillos=2);
//
//    translate([ 10,0, 0])rotate([90, 0, 0])
//    hueco_baqueta(cantidad_tornillos=2);
//}
use <juntas.scad>;
// holgura para pico de 0.8 en bambu a1l version extra draft custom
holgura_a       = 1.25;    // holgura radial extremo A
holgura_b       = 1.5;    // holgura radial extremo B

junta_doble(holgura_a=holgura_a, holgura_b=holgura_b);
