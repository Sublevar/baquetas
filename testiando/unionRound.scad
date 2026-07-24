


radio= 10;
altura=10;
largo=60;
escalaY=0;
escalaX=0.33;
// Demo code
 unionRound(50, 1) {
     cylinder(r=radio,h=altura,center=true);
     translate([radio,0, 0])rotate([0, 90, 0])scale([0.66,1,1])
     cylinder(r=altura,h=largo);
} // end of demo code


 unionRound(50, 1) {
     cylinder(r=radio,h=altura,center=true);
     translate([radio,0, 0])rotate([0, 90, 0])scale([0.66,1,1])
     cylinder(r=altura,h=largo);
} // end of demo code
module unionRound(r, detail = 5) {
    epsilon = 1e-6;
    children(0);
    children(1);
    step = 1 / detail;
    for (i = [0: step: 1 - step]) {
        {
            x = r - sin(i * 90) * r;
            y = r - cos(i * 90) * r;
            xi = r - sin((i + step) * 90) * r;
            yi = r - cos((i + step) * 90) * r;
           // color(rands(0, 1, 3, i))
            hull() {
                intersection() {
                    // shell(epsilon) 
                    clad(x) children(0);
                    // shell(epsilon) 
                    clad(y) children(1);
                }
                intersection() {
                    // shell(epsilon) 
                    clad(xi) children(0);
                    // shell(epsilon) 
                    clad(yi) children(1);
                }
            }
        }
    }
}
// unionRound helper expand by r
module clad(r) {
    minkowski() {
        children();
        //        icosphere(r,2);
        sphere(r, $fn = 19.5);
    }
}
// unionRound helper
module shell(r) {
    difference() {
        clad(r) children();
        children();
    }
}