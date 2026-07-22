use <tuercas_metricas.scad>;
use <tuerca_UNC-UNF.scad>;
//use <"tuerca_whitworth.scad">;

poly_n = 16;
margen=.5;

d = 24+margen;
ancho_baqueta= 30;

r= d/2;
largo_palo=120;
 
//automatizar el uso y tipificacion de tuerca
echo("1/4 normal:", tuerca_unc(0.25, "normal"));
c=tuerca_unc(0.25, "normal")[0];
grosor=d+tuerca_unc(0.25, "normal")[0] *2;
sagita = r-sqrt( pow(r,2) - pow(c/2,2) ) + margen;

 difference(){
   rotate([0,90,0])
  {
    difference(){
    cylinder(d=grosor,h=ancho_baqueta, center=true, $fn=poly_n);
    cylinder(d=d,h=largo_palo, center=true, $fn=poly_n);
   }
  }
  
  
    translate([0,0,r])agujero_con_tuerca_unc(0.25, profundidad_pieza = 12, alivio=sagita);
//PARAMETRIZAR ESTAS OPCIONES UNA VEZ DEFINIDO SI SON HUECOS O SON FORMAS POSITIVAS A RESTAR : ESTUDIAR CHILDREN()
//  
//for (i=[0:1:2]){
// rotate([180*i,0,0])translate([0,0,r]){
//  agujero_con_tuerca_unc(0.25, profundidad_pieza = 12, alivio=sagita);
//  }
// }
 
  //for (i=[0:1:4]){
  // rotate([90*i,0,0])translate([0,0,r]){
  //  agujero_con_tuerca_unc(0.25, profundidad_pieza = 12, alivio=sagita);
  //  }
  // }
  // }
  
  
//  for (i=[0:1:3]){
//    rotate([120*i,0,0])translate([0,0,r]){
//     agujero_con_tuerca_unc(0.25, profundidad_pieza = 12, alivio=sagita);
//     }
//   }
  
//  for (i=[0:1:6]){
//    rotate([60*i,0,0])translate([0,0,r]){
//     agujero_con_tuerca_unc(0.25, profundidad_pieza = 12, alivio=sagita);
//     }
//   }
 }
