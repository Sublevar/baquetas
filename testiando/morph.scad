RADIUS = 4;
STEPS  = 15;
function ease_grow(t)   = cos(180 + 90*t) + 1;   // 0 -> 1
function ease_shrink(t) = sin(180 + 90*t) + 1;   // 1 -> 0
// children(0) = pieza A, children(1) = pieza B
// Ambas deben leer la variable especial $mix (0..1) para saber cómo lucir.
module morph(steps = 15){
    for(i = [0 : steps-2]){
        m1 = i     / (steps-1);
        m2 = (i+1) / (steps-1);
        hull(){
            intersection(){ $mix = m1; children(0); children(1); }
            intersection(){ $mix = m2; children(0); children(1); }
        }
    }
}

module part_1(){
    mix = is_undef($mix) ? 0 : $mix;
    r = 3 + RADIUS*ease_grow(mix);
    sphere(r = r, $fn = 100);
}
module part_2(){
    mix = is_undef($mix) ? 1 : $mix;
    r = 3 + RADIUS*ease_shrink(mix);
    translate([8 + 2*sin(360*$t), 0, 0])
    sphere(r = r, $fn = 100);
}

for(j = [0:5])
    rotate([0, 0, j*360/6])
    //color([.2, .6, .8, .3])
    morph(STEPS){
        part_1();
        part_2();
    }

//color([.2, .6, .8, .3]) part_1();          // tapa: $mix por defecto = 0
//for(j = [0:5])
//    rotate([0, 0, j*360/6])
//    color([.2, .6, .8, .3])
//    part_2();                              // tapa: $mix por defecto = 1