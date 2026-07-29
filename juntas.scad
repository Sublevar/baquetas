use <hueco_baqueta.scad>;

 poly_n = 12;
 diametro = 7;
 radio= diametro/2;
 altura =18;
 distancia=40;
 ancho_baqueta=40;
 rotacion=120;
 cantidad=5;
 
 //JUNTAS DOBLES
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
    
      
 translate([-100,-50,0])
difference() {
 
 hull(){
    rotate([0,0,90])baqueta_solida(ancho_baqueta=ancho_baqueta);
translate([distancia, 0,0])rotate([0,0,90])
    baqueta_solida(ancho_baqueta=ancho_baqueta);
}

  rotate([0,0,90])
hueco_baqueta(cantidad_tornillos=2);;
translate([distancia, 0,0])rotate([0,0,90])
    hueco_baqueta(cantidad_tornillos=2);
    }
 
 translate([-100,50,0])
difference() {
 
 hull(){
    rotate([0,90,90])baqueta_solida(ancho_baqueta=ancho_baqueta);
translate([distancia, 0,0])rotate([0,rotacion,90])
    baqueta_solida(ancho_baqueta=ancho_baqueta);
}

  rotate([0,90,90])
hueco_baqueta(cantidad_tornillos=2);;
translate([distancia, 0,0])rotate([0,rotacion,90])
    hueco_baqueta(cantidad_tornillos=2);
    }
 
    
 //array
    //TODO: altaerna entre rotacion y no rotacion, y solo rotar n posiciones (ej extremos o uno en especifico)
    rotTotal=90;
   rotParcial= rotTotal/(cantidad-1);
    translate([100,0,0]){
 difference() {
  hull(){
 for (i =[1:cantidad]){translate([distancia*i, 0,0])
  rotate([0,rotParcial*i,90])
    baqueta_solida(ancho_baqueta=ancho_baqueta);
}}

 for (i =[1:cantidad]){translate([distancia*i, 0,0])
  
  rotate([0,rotParcial*i,90])
 hueco_baqueta(cantidad_tornillos=2,profundidad_pieza=20);
  }}
 }
 
 rotacionPrincipal =90;
 rotacionCuerpo= 45;
   //array y 2 tipos de angulsoangulos
    //TODO: altaerna entre rotacion y no rotacion, y solo rotar n posiciones (ej extremos o uno en especifico)
//        rotTotal=90;
//   rotParcial= rotTotal/(cantidad-1);
    translate([100,-150,0]){
 difference() {
  hull(){
 for (i =[1:cantidad]){translate([distancia*i, 0,0]){
rotate([0, (i==1 || i==cantidad) ? rotacionPrincipal : rotacionCuerpo, 90])
     baqueta_solida(ancho_baqueta=ancho_baqueta);
 }
}
}
 for (i =[1:cantidad]){translate([distancia*i, 0,0]){
rotate([0, (i==1 || i==cantidad) ? rotacionPrincipal :rotacionCuerpo , 90])
 hueco_baqueta(cantidad_tornillos=2,profundidad_pieza=20);
 
 }}
 }
}


   //array y degrade de angulos
    //TODO: altaerna entre rotacion y no rotacion, y solo rotar n posiciones (ej extremos o uno en especifico)
//        rotTotal=90;
//   rotParcial= rotTotal/(cantidad-1);
    translate([100,-250,0]){
 difference() {
  hull(){
 for (i =[1:cantidad]){translate([distancia*i, 0,0]){
rotate([0, (i==1 || i==cantidad) ? rotTotal : rotParcial*i, 90])
     baqueta_solida(ancho_baqueta=ancho_baqueta);
 }
}
}
 for (i =[1:cantidad]){translate([distancia*i, 0,0]){
rotate([0, (i==1 || i==cantidad) ? rotTotal : rotParcial*i, 90])
 hueco_baqueta(cantidad_tornillos=2,profundidad_pieza=20);
 
 }}
 }
}
 
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



 //junta T

  desface_centro = [0,0,-5];
 translate([100,100,0]){
   difference() {

 hull(){
baqueta_solida(ancho_baqueta=60);
  translate([ancho_baqueta, 0, 0.0])rotate([0,90,0])
baqueta_solida(ancho_baqueta=60);
}
 hueco_baqueta(cantidad_tornillos=2,profundidad_pieza=20,largo_hueco_principal=60,desface_centro=desface_centro);
  translate([ancho_baqueta, 0, 0.0])rotate([0,90,0])
 hueco_baqueta(cantidad_tornillos=1,profundidad_pieza=20,largo_hueco_principal=60);
}

}

//union lineal
desface_centro = [0,0,-5];
 translate([300,100,0]){
   difference() {

 hull(){
baqueta_solida(ancho_baqueta=60);
  translate([ancho_baqueta, 0, 0.0])
baqueta_solida(ancho_baqueta=60);
}
 hueco_baqueta(cantidad_tornillos=2,profundidad_pieza=20,largo_hueco_principal=ancho_baqueta,desface_centro=desface_centro);
  translate([ancho_baqueta, 0, 0.0])
 hueco_baqueta(cantidad_tornillos=2,profundidad_pieza=20,largo_hueco_principal=ancho_baqueta,desface_centro=-ancho_baqueta);
}

}
ancho_baqueta=60;
 translate([300,150,0])

translate([ancho_baqueta, 0, 0.0])
 hueco_baqueta(cantidad_tornillos=2,profundidad_pieza=20,largo_hueco_principal=ancho_baqueta,desface_centro=-ancho_baqueta);


//Terminal / tapon
translate([300,200,0]){
   difference() {

baqueta_solida(ancho_baqueta=60);

 hueco_baqueta(cantidad_tornillos=2,profundidad_pieza=20,largo_hueco_principal=ancho_baqueta,desface_centro=desface_centro);
  
}

}


//op con cosas
desface_centro = [0,0,-5];
d=22;
r=d/2;
translate([300,200,0]){
   difference() {
//hull
union(){
baqueta_solida(ancho_baqueta=60);
 translate([ancho_baqueta*0.75-r+desface_centro[2], 0, 0.0]) //no entiendo por que le clavo el .75 y funciona
sphere(d);
}
 hueco_baqueta(cantidad_tornillos=2,profundidad_pieza=20,largo_hueco_principal=ancho_baqueta,desface_centro=desface_centro);
  
}

}

//cruz
//    translate([100,100,0]){
// difference() {
//
// hull(){
//    baqueta_solida(ancho_baqueta=60);
//translate([0, 0, 0.0])rotate([0,90,90])
//    baqueta_solida(ancho_baqueta=60);
//}
//     hueco_baqueta(cantidad_tornillos=2);
//
// translate([0, 0, 0.0])rotate([0,90,90])
//    hueco_baqueta(cantidad_tornillos=4,profundidad_pieza=20);
// }
//}

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

