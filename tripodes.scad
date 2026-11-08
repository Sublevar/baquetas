include <config.scad>
use <hueco_baqueta.scad>
use <utils/acople.scad>
use <utils/trigonometria.scad>

/* ============================================================
   TRIPODES
     - pie_tripode: hub con un hueco central (poste, boca arriba) y
                    n patas ciegas que salen hacia abajo y afuera.
     - punta_pata : zapata para el extremo de cada pata, con la base
                    cortada plana contra el piso y rebaje para goma.

   El nodo (cruce de los ejes de las patas con el eje del poste) queda
   en el origen del hub. En la punta, el origen es el punto donde el eje
   de la pata toca el piso (z = 0).

   apertura: angulo de cada pata respecto de la vertical.
   Largo de la pata entre ejes = altura_nodo / cos(apertura); el largo a
   cortar descuenta el fondo del hub y el de la punta: calculadora.scad.
   ============================================================ */

/* ---------- HUB ---------- */
module pie_tripode(
    patas              = 3,
    apertura           = 25,
    distancia_pieza    = 0,      // nodo -> boca de cada pata; 0 = minimo calculado
    profundidad_hueco  = 45,     // de las patas
    profundidad_poste  = 45,
    piso_poste         = 6,      // macizo bajo el fondo del hueco del poste
    cantidad_tornillos = 1,
    angulo_tornillo_poste = 0,
    angulo_tornillo_pata  = 0,   // 0: sale hacia afuera y arriba
    profundidad_pieza  = _profundidad,
    pared              = _pared_min,
    diametro           = _diametro,
    holgura            = _holgura,
    poly_n             = _poly_n,
    familia_tuerca     = _familia_tuerca,
    subtipo_tuerca     = _subtipo_tuerca,
    medida_tornillo    = _medida_tornillo
) {
    r_h    = (diametro + holgura) / 2;
    fondo  = max(fondo_radial(r_h, pared, apertura, patas),
                 fondo_sobre_plano(r_h, pared, apertura));
    boca_m = fondo + profundidad_hueco;
    boca   = distancia_pieza > 0 ? distancia_pieza : boca_m;
    largo_poste = profundidad_poste + piso_poste;

    if (boca < boca_m - 0.01)
        echo(str("ADVERTENCIA pie_tripode: distancia_pieza=", boca,
                 " < minimo ", r1(boca_m), " mm (los huecos de las patas quedan muy cerca)"));

    // pata i: hacia abajo y afuera, `apertura` grados desde la vertical
    module marco_pata(i) rotate([0, 0, i * 360 / patas]) rotate([0, 90 - apertura, 0]) children();
    module marco_poste() rotate([0, -90, 0]) children();

    difference() {
        union() {
            marco_poste()
                acople_cuerpo(
                    largo = largo_poste, diametro = diametro, holgura = holgura, poly_n = poly_n,
                    familia_tuerca = familia_tuerca, subtipo_tuerca = subtipo_tuerca,
                    medida_tornillo = medida_tornillo
                );
            for (i = [0 : patas - 1]) marco_pata(i)
                acople_cuerpo(
                    largo = boca, diametro = diametro, holgura = holgura, poly_n = poly_n,
                    familia_tuerca = familia_tuerca, subtipo_tuerca = subtipo_tuerca,
                    medida_tornillo = medida_tornillo
                );
        }
        marco_poste()
            acople_hueco(
                largo = largo_poste, profundidad_hueco = profundidad_poste,
                cantidad_tornillos = cantidad_tornillos, angulo_tornillo = angulo_tornillo_poste,
                profundidad_pieza = profundidad_pieza,
                diametro = diametro, holgura = holgura, poly_n = poly_n,
                familia_tuerca = familia_tuerca, subtipo_tuerca = subtipo_tuerca,
                medida_tornillo = medida_tornillo
            );
        for (i = [0 : patas - 1]) marco_pata(i)
            acople_hueco(
                largo = boca, profundidad_hueco = profundidad_hueco,
                cantidad_tornillos = cantidad_tornillos, angulo_tornillo = angulo_tornillo_pata,
                profundidad_pieza = profundidad_pieza,
                diametro = diametro, holgura = holgura, poly_n = poly_n,
                familia_tuerca = familia_tuerca, subtipo_tuerca = subtipo_tuerca,
                medida_tornillo = medida_tornillo
            );
    }
}

/* ---------- PUNTA ----------
   La pata llega inclinada `apertura` desde la vertical (hacia adentro y
   arriba). El cilindro se corta con el plano z = 0 y queda una base
   eliptica; se le suma un disco horizontal (pie) y un rebaje para goma. */
module punta_pata(
    apertura           = 25,
    profundidad_hueco  = 45,
    piso               = 5,      // macizo entre el fondo del hueco y el piso
    d_pie              = 0,      // disco de apoyo; 0 = grosor del cuerpo + 16
    espesor_pie        = 4,
    rebaje_goma        = true,
    d_goma             = 40,
    prof_goma          = 1.5,
    cantidad_tornillos = 1,
    angulo_tornillo    = 0,
    profundidad_pieza  = _profundidad,
    diametro           = _diametro,
    holgura            = _holgura,
    poly_n             = _poly_n,
    familia_tuerca     = _familia_tuerca,
    subtipo_tuerca     = _subtipo_tuerca,
    medida_tornillo    = _medida_tornillo
) {
    g     = grosor_baqueta(diametro, holgura, familia_tuerca, subtipo_tuerca, medida_tornillo);
    r_h   = (diametro + holgura) / 2;
    t_b   = fondo_sobre_plano(r_h, piso, apertura);   // piso -> fondo del hueco, por el eje
    t_m   = t_b + profundidad_hueco;                  // boca
    ext   = g / 2 * tan(apertura) + 1;                // el cilindro arranca bajo el piso
    d_p   = d_pie > 0 ? d_pie : g + 16;

    // eje de la pata: sube hacia adentro (-X) desde el punto de apoyo
    module marco_eje() rotate([0, -(90 + apertura), 0]) children();

    intersection() {
        difference() {
            union() {
                marco_eje() translate([-ext, 0, 0])
                    acople_cuerpo(
                        largo = t_m + ext, diametro = diametro, holgura = holgura, poly_n = poly_n,
                        familia_tuerca = familia_tuerca, subtipo_tuerca = subtipo_tuerca,
                        medida_tornillo = medida_tornillo
                    );
                cylinder(d = d_p, h = espesor_pie, $fn = 48);
            }
            marco_eje()
                acople_hueco(
                    largo = t_m, profundidad_hueco = profundidad_hueco,
                    cantidad_tornillos = cantidad_tornillos, angulo_tornillo = angulo_tornillo,
                    profundidad_pieza = profundidad_pieza,
                    diametro = diametro, holgura = holgura, poly_n = poly_n,
                    familia_tuerca = familia_tuerca, subtipo_tuerca = subtipo_tuerca,
                    medida_tornillo = medida_tornillo
                );
            if (rebaje_goma)
                translate([0, 0, -1]) cylinder(d = d_goma, h = prof_goma + 1, $fn = 48);
        }
        // nada bajo el piso
        translate([-1000, -1000, 0]) cube([2000, 2000, 2000]);
    }
}

/* ============================================================
   DEMO
   ============================================================ */

// Hub de 3 patas a 25 grados
pie_tripode();

// Hub de 4 patas a 20 grados
translate([0, 300, 0]) pie_tripode(patas = 4, apertura = 20);

// Punta para pata a 25 grados
translate([250, 0, 0]) punta_pata();
