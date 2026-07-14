
 poly_n = 6;
 diametro = 7;
 radio= diametro/2;
 altura =4;
 
 
 //color("#aa0000")cylinder(h = altura, d=diametro, center = true, $fn=poly_n);
 // translate([0, 10, 0.0])
  
  
difference(){
hull(){
  cylinder(h = altura, d=diametro, center = true, $fn=poly_n); 
  translate([radio, 0, 0.0])
  cube([2,2,altura],center = true);
 }
    cylinder(h = altura, d=diametro*.5, center = true, $fn=poly_n);
}

translate([10+radio+1, 0, 0.0]){
 difference(){
hull(){
   cylinder(h = altura, d=diametro, center = true, $fn=poly_n);
  translate([-radio, 0, 0.0])
  cube([2,2,altura],center = true);
 }
   cylinder(h = altura, d=diametro*.5, center = true, $fn=poly_n);
}}


//------------------------

translate([ 0, 10.0]){
difference(){
hull(){
  cylinder(h = altura, d=diametro, center = true, $fn=poly_n); 
  translate([radio, 0, 0.0])
  cube([2,2,altura],center = true);
  translate([10+radio+1, 0, 0.0]){
  cylinder(h = altura, d=diametro, center = true, $fn=poly_n);
  translate([-radio, 0, 0.0])
  cube([2,2,altura],center = true);
   }
}
  cylinder(h = altura, d=diametro*.5, center = true, $fn=poly_n);
  translate([10+radio+1, 0, 0.0]){
  cylinder(h = altura, d=diametro*.5, center = true, $fn=poly_n);
}}}


//------------------------

translate([ 0, 20.0]){
difference(){
union(){
hull(){
  cylinder(h = altura, d=diametro, center = true, $fn=poly_n); 
  translate([radio, 0, 0.0])
  cube([2,2,altura],center = true);
 }
 hull(){
   cube([2,2,altura],center = true);
   translate([10+radio+1, 0, 0.0])

translate([-radio, 0, 0.0])
  cube([2,2,altura],center = true);
  }
 
 translate([10+radio+1, 0, 0.0]){
  hull(){
  cylinder(h = altura, d=diametro, center = true, $fn=poly_n);
  translate([-radio, 0, 0.0])
  cube([2,2,altura],center = true);
   }
  }
 }
  cylinder(h = altura, d=diametro*.5, center = true, $fn=poly_n);
  translate([10+radio+1, 0, 0.0]){
  cylinder(h = altura, d=diametro*.5, center = true, $fn=poly_n);
}}}

//---------- tema acple hirts y mejor degradado entre partes!!!!

rotarJunta= 45;
translate([ 0, 30.0]){
difference(){
union(){
hull(){
 rotate([rotarJunta,0,0]){
  cylinder(h = altura, d=diametro, center = true, $fn=poly_n); 
  translate([radio, 0, 0.0])
  cube([2,2,altura],center = true);
 }}
 hull(){
   cube([2,2,altura],center = true);
   translate([10+radio+1, 0, 0.0])

translate([-radio, 0, 0.0])
  cube([2,2,altura],center = true);
  }
 
 translate([10+radio+1, 0, 0.0]){
  hull(){
  cylinder(h = altura, d=diametro, center = true, $fn=poly_n);
  translate([-radio, 0, 0.0])
  cube([2,2,altura],center = true);
   }
  }
 } 
   rotate([rotarJunta,0,0]){
    cylinder(h = altura, d=diametro*.5, center = true, $fn=poly_n);
   }
  translate([10+radio+1, 0, 0.0]){
  cylinder(h = altura, d=diametro*.5, center = true, $fn=poly_n);
}}}
//
//minkowski(){
// 
//   translate([0, 0,-altura/2.0])
//
//  cube([2,2,altura]);
//  translate([10, 0, 0.0])
//
// cylinder(h = altura, d=diametro, center = true, $fn=poly_n);
//
// }