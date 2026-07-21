
 poly_n = 16;
 diametro = 22;
 radio= diametro/2;
 grosor= 4;
 altura =70;
 
 
 //color("#aa0000")cylinder(h = altura, d=diametro, center = true, $fn=poly_n);
 // translate([0, 10, 0.0])
 difference(){
    hull(){
    translate([0, 0, altura/2])//punta centrada
    sphere( d=diametro+grosor, $fn=poly_n);
    cylinder(h = altura, d=diametro+grosor, center = true, $fn=poly_n);
     }
    translate([0, 0, -grosor])
    cylinder(h = altura-grosor, d=diametro, center = true, $fn=poly_n);
 }

translate([0, 50,0])
rotate([0,90,0])
  difference(){
    cylinder(h = altura, d=diametro+grosor, center = true, $fn=poly_n);
    cylinder(h = altura, d=diametro, center = true, $fn=poly_n);
 }
translate([0, -50,0])

linear_extrude(height=altura,center=true)//,twist=90
    scale([5,2,10])
    circle(d=10);
//  cylinder(h=altura,d1=diametro,d2=altura
// translate([0, -50,0])
//
// module rounded_car_body(length=80, rear_height=20, rear_width=25, scaling_factor=0.5) {
//rotate([0,-90,0])
//    linear_extrude(height=length,center=true,scale=scaling_factor)
//    resize([rear_height,rear_width])
//    circle(d=rear_height);    
//}