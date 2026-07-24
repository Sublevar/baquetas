use <hueco_baqueta.scad>;





 poly_n = 12;
 diametro = 7;
 radio= diametro/2;
 altura =18;
 distancia=40;
 ancho_baqueta=40;
 rotacion=120;
 cantidad=5;
 
 
difference() {
 
 hull(){
    rotate([0,90,90])baqueta_solida(ancho_baqueta=ancho_baqueta);
translate([distancia, 0,0])rotate([0,0,90])
    baqueta_solida(ancho_baqueta=ancho_baqueta);
}

  rotate([0,90,90]) hueco_baqueta(cantidad_tornillos=2);;
translate([distancia, 0,0])rotate([0,0,90])
     hueco_baqueta(cantidad_tornillos=2);
    }
 
 //array
// difference() {
//  hull(){
// for (i =[0:cantidad]){translate([distancia*i, 0,0])rotate([0,0,90])
//    baqueta_solida(ancho_baqueta=ancho_baqueta);
//}}
//
// for (i =[0:cantidad]){translate([distancia*i, 0,0])rotate([0,0,90])
// hueco_baqueta(cantidad_tornillos=2);}}
 
 
 
 //angulo variable
//difference() {
// 
// hull(){
//    rotate([0,0,90])baqueta_solida(ancho_baqueta=ancho_baqueta);
//translate([distancia, 0,0])rotate([0,rotacion,90])
//    baqueta_solida(ancho_baqueta=ancho_baqueta);
//}
//
//  rotate([0,0,90]) hueco_baqueta(cantidad_tornillos=2);;
//translate([distancia, 0,0])rotate([0,rotacion,90])
//     hueco_baqueta(cantidad_tornillos=2);
//    }
//    
    
    // a 90 grados
//difference() {
// 
// hull(){
//    rotate([0,90,90])baqueta_solida(ancho_baqueta=ancho_baqueta);
//translate([distancia, 0,0])rotate([0,0,90])
//    baqueta_solida(ancho_baqueta=ancho_baqueta);
//}
//
//  rotate([0,90,90]) hueco_baqueta(cantidad_tornillos=2);;
//translate([distancia, 0,0])rotate([0,0,90])
//     hueco_baqueta(cantidad_tornillos=2);
//    }




//cruz
//
// hull(){
//    rotate([0,90,90])baqueta_solida(ancho_baqueta=60);
//translate([0, 0, 0.0])rotate([0,0,90])
//    baqueta_solida(ancho_baqueta=60);
//}


// difference() {
//
// hull(){
//    baqueta_solida(ancho_baqueta=60);
//translate([diametro, 0, 0.0])rotate([0,90,90])
//    baqueta_solida(ancho_baqueta=60);
//}
//     hueco_baqueta(cantidad_tornillos=2);
//
// translate([diametro, 0, 0.0])rotate([0,90,90])
//    hueco_baqueta(cantidad_tornillos=2);
// }

 //color("#aa0000")cylinder(h = altura, d=diametro, center = true, $fn=poly_n);
 // translate([0, 10, 0.0])
////hull(){
////cylinder(h = altura, d=diametro, center = true, $fn=poly_n); 
////translate([diametro, 0, 0.0])rotate([0,90,90])
////cylinder(h = altura, d=diametro, center = true, $fn=poly_n); 
////}
  
  
  
 
 //T
// hull(){
//cylinder(h = altura, d=diametro, center = true, $fn=poly_n); 
//translate([diametro, 0, 0.0])rotate([0,90,0])
//cylinder(h = altura, d=diametro, center = true, $fn=poly_n); 
//}
  
 
//difference(){
//hull(){
//  cylinder(h = altura, d=diametro, center = true, $fn=poly_n); 
//  translate([radio, 0, 0.0])
//  cube([2,2,altura],center = true);
// }
//    cylinder(h = altura, d=diametro*.5, center = true, $fn=poly_n);
//}
//
//translate([10+radio+1, 0, 0.0]){
// difference(){
//hull(){
//   cylinder(h = altura, d=diametro, center = true, $fn=poly_n);
//  translate([-radio, 0, 0.0])
//  cube([2,2,altura],center = true);
// }
//   cylinder(h = altura, d=diametro*.5, center = true, $fn=poly_n);
//}}

