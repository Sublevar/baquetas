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


junta_doble();
