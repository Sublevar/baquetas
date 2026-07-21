
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
  difference(){
    cylinder(h = altura, d=diametro+grosor, center = true, $fn=poly_n);
    translate([0, 0, -grosor])
    cylinder(h = altura-grosor, d=diametro, center = true, $fn=poly_n);
 }
   