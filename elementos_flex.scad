include <config.scad>
use <hueco_baqueta.scad>
use <utils/acople.scad>
use <sin_tornillo.scad>

/* ============================================================
   ELEMENTOS SIN TORNILLO  (familia de piezas al estilo CHOIS)
   Piezas para armar muebles y accesorios con palos de escoba (22-24 mm,
   no del todo simetricos) sin tornillos: cada pieza se sujeta al palo
   con los brazos flexibles de sin_tornillo.scad, o se apoya contra un
   manguito de tope, como en el Hanger Bar de CHOIS.

     manguito_tope  : manguito pasante con brida; se desliza y frena
     hub_cruce      : dos palos que se cruzan (barra horizontal + pilar)
     bandeja        : bandeja redonda con borde y nervios
     canasto        : bandeja alta, con el fondo y el borde calados
     brazo_estante  : brazo con labio para apoyar una tabla
     multi_gancho   : tres ganchos inclinados sobre un collar
     base_flex      : base con cono para pararse en el piso
     tapa_plato     : tapa con plato para el extremo del palo

   Todas se imprimen DE PIE, con la boca del palo hacia arriba y el plato o
   la brida contra la cama: los brazos flexibles trabajan en el plano de capa.
   ============================================================ */

/* ============================================================
   PRUEBAS PENDIENTES  (editar despues de imprimir y probar)
   Nada de esto esta probado impreso. Lo que hay que revisar y donde cambiarlo:

   [ ] Agarre del palo: precarga, rango de palos, espesor de brazos
         -> config.scad, bloque "PALO DE ESCOBA" (_palo_*)
   [ ] Holgura de los palos en el hub (se apoyan contra los manguitos)
         -> _holgura_hub (abajo) o el parametro holgura_hub
   [ ] Carga maxima que sostiene cada pieza por friccion
         -> el agarre estimado con el palo fino es de ~4.5 N: sirve para livianos.
            Si una pieza se corre, apoyarla sobre un manguito_tope (no solo por friccion)
            o subir la precarga.
   [ ] Grosor del plato / nervios / borde de bandeja y canasto segun lo que carguen
   [ ] Si el hub o los ganchos necesitan soporte al imprimir (ver notas en cada modulo)
   Buscar en este archivo las marcas "PRUEBAS:" para ver cada punto en su lugar.
   ============================================================ */

_holgura_hub = 0.8;     // PRUEBAS: juego radial de los palos dentro del hub (mm)

_g = grosor_baqueta(_diametro, _holgura, _familia_tuerca, _subtipo_tuerca, _medida_tornillo);

// eje X del acople -> Z, boca hacia arriba
module vertical() rotate([0, -90, 0]) children();

/* ---------- MANGUITO CON BRIDA ----------
   Equivale al "locking sleeve" de CHOIS: se desliza por el palo y la brida
   apoya contra la pieza que se quiere frenar (hub, bandeja, brazo).
   PRUEBAS: alto y diametro de la brida segun la carga que tenga que frenar. */
module manguito_tope(
    largo       = 60,
    extra_brida = 14,
    alto_brida  = 5
) {
    difference() {
        union() {
            vertical() cuerpo_flex(largo);
            cylinder(d = _g + extra_brida, h = alto_brida, $fn = 64);
        }
        vertical() agujero_flex_pasante(largo, largo_flex = 28);
    }
}

/* ---------- HUB DE CRUCE ----------
   Dos agujeros rectos y sueltos que se cruzan a distinta altura: el pilar
   vertical y la barra horizontal, separados lo justo para dejar `pared`
   entre ambos. NO sujeta nada por si mismo: los palos se frenan con
   manguito_tope a cada lado (como el Hanger Bar de CHOIS).
   gota = true: el agujero horizontal lleva la parte superior en punta (45 grados)
   para imprimir de pie sin soporte.
   PRUEBAS: holgura_hub; si la gota no alcanza, imprimir con soporte o rotar la pieza. */
module hub_cruce(
    holgura_hub = _holgura_hub,
    gota        = true,
    pared       = _pared_min
) {
    r_h = (_palo_max + _palo_ovalidad) / 2 + holgura_hub;
    e   = 2 * r_h + pared;            // separacion de ejes
    difference() {
        hull() {
            cylinder(d = _g, h = _g, center = true, $fn = _poly_n);
            translate([0, e, 0]) rotate([0, 90, 0]) cylinder(d = _g, h = _g, center = true, $fn = _poly_n);
        }
        // pilar vertical
        cylinder(r = r_h, h = _g * 3, center = true, $fn = 64);
        // barra horizontal (eje X), con gota hacia +Z
        translate([0, e, 0]) rotate([0, 90, 0]) linear_extrude(height = _g * 3, center = true)
            hull() {
                circle(r = r_h, $fn = 64);
                if (gota) translate([-r_h * 1.4142, 0]) square(0.01, center = true);   // -x local = +Z
            }
    }
}

/* ---------- BANDEJA ----------
   Fondo plano contra la cama, borde y nervios radiales por arriba; el cubo
   central con zonas flexibles en ambos extremos baja por el fondo.
   d = 200 entra en una cama de 256 mm.
   PRUEBAS: espesor del fondo (esp), nervios y alto del borde segun la carga.
            Apoyarla sobre un manguito_tope; el agarre por friccion es bajo. */
module bandeja(
    d            = 200,
    alto_borde   = 25,
    esp          = 4,
    pared_borde  = 2.4,
    nervios      = 6,
    alto_nervio  = 12,
    largo_hub    = 70,
    calado       = false,      // agujeros en el fondo (canasto)
    d_calado     = 14,
    paso_calado  = 22,
    ranuras_borde = 0,         // ranuras verticales en el borde (canasto)
    ancho_ranura  = 10
) {
    R = d / 2;
    difference() {
        union() {
            vertical() cuerpo_flex(largo_hub);
            cylinder(r = R, h = esp, $fn = 96);
            difference() {                                   // borde
                cylinder(r = R, h = alto_borde, $fn = 96);
                translate([0, 0, -1]) cylinder(r = R - pared_borde, h = alto_borde + 2, $fn = 96);
            }
            for (i = [0 : nervios - 1])                       // nervios radiales
                rotate([0, 0, i * 360 / nervios])
                    translate([_g / 2 - 2, -pared_borde / 2, 0])
                        cube([R - _g / 2 - pared_borde + 3, pared_borde, min(alto_nervio, alto_borde)]);
        }
        vertical() agujero_flex_pasante(largo_hub, largo_flex = 28);
        if (calado)
            for (r = [_g / 2 + 16 : paso_calado : R - pared_borde - d_calado / 2 - 4]) {
                n = floor(2 * PI * r / paso_calado);
                for (k = [0 : n - 1]) {
                    a = k * 360 / n;
                    // deja macizo el camino de los nervios: el agujero queda al menos a
                    // (radio del agujero + media pared + 1.5 mm) de la linea del nervio
                    if (nervios == 0 || abs(((a % (360 / nervios)) + 360 / nervios / 2) % (360 / nervios) - 360 / nervios / 2)
                                        > asin((d_calado / 2 + pared_borde / 2 + 1.5) / r))
                        translate([r * cos(a), r * sin(a), -1]) cylinder(d = d_calado, h = esp + 2, $fn = 24);
                }
            }
        if (ranuras_borde > 0)
            for (k = [0 : ranuras_borde - 1])
                rotate([0, 0, (k + 0.5) * 360 / ranuras_borde])
                    translate([R - pared_borde - 1, -ancho_ranura / 2, 12])
                        cube([pared_borde + 2, ancho_ranura, max(alto_borde - 22, 1)]);
    }
}

/* ---------- CANASTO ----------
   Bandeja alta con el fondo y el borde calados: para frutas, ropa, juguetes.
   PRUEBAS: el borde alto es la parte mas debil; subir pared_borde o bajar las
            ranuras si se flexiona. */
module canasto(
    d             = 190,
    alto_borde    = 80,
    pared_borde   = 3.2,
    largo_hub     = 95,
    ranuras_borde = 16
) {
    bandeja(d = d, alto_borde = alto_borde, pared_borde = pared_borde, largo_hub = largo_hub,
            nervios = 6, alto_nervio = 20, calado = true, ranuras_borde = ranuras_borde, ancho_ranura = 12);
}

/* ---------- BRAZO DE ESTANTE ----------
   Collar vertical con una placa horizontal arriba y un labio al final, para
   apoyar una tabla. Cartela a 45 grados bajo la placa (se imprime sin soporte).
   PRUEBAS: espesor de la placa y de la cartela segun el peso de la tabla.
            Apoyar el collar sobre un manguito_tope: por friccion sola resbala. */
module brazo_estante(
    largo_collar = 100,
    largo_brazo  = 130,
    ancho        = 50,
    esp          = 8,
    alto_labio   = 10,
    ancho_labio  = 5,
    cartela      = true,
    esp_cartela  = 8
) {
    difference() {
        union() {
            vertical() cuerpo_flex(largo_collar);
            translate([0, -ancho / 2, largo_collar - esp]) cube([largo_brazo, ancho, esp]);
            translate([largo_brazo - ancho_labio, -ancho / 2, largo_collar - esp])
                cube([ancho_labio, ancho, esp + alto_labio]);
            if (cartela)
                translate([0, 0, largo_collar - esp]) rotate([90, 0, 0])
                    linear_extrude(height = esp_cartela, center = true)
                        polygon([[_g / 2 - 1, 0], [largo_brazo * 0.6, 0],
                                 [_g / 2 - 1, -(largo_brazo * 0.6 - _g / 2 + 1)]]);
        }
        vertical() agujero_flex_pasante(largo_collar, largo_flex = 28);
    }
}

/* ---------- MULTI GANCHO ----------
   Tres (o n) ganchos tipo clavija, inclinados hacia arriba, sobre un collar.
   A 50 grados sobre la horizontal el voladizo imprime sin soporte.
   PRUEBAS: diametro y largo de las clavijas segun lo que cuelgue (ropa, bolsos). */
module multi_gancho(
    n            = 3,
    largo_collar = 80,
    largo_gancho = 75,
    d_gancho     = 14,
    angulo       = 50,
    d_bola       = 24,
    alto_gancho  = 0.55            // altura de la base de las clavijas, fraccion del collar
) {
    difference() {
        union() {
            vertical() cuerpo_flex(largo_collar);
            for (i = [0 : n - 1])
                rotate([0, 0, i * 360 / n])
                    translate([0, 0, largo_collar * alto_gancho]) rotate([0, 90 - angulo, 0]) {
                        cylinder(d = d_gancho, h = largo_gancho, $fn = 32);
                        translate([0, 0, largo_gancho]) sphere(d = d_bola, $fn = 32);
                    }
        }
        vertical() agujero_flex_pasante(largo_collar, largo_flex = 28);
    }
}

/* ---------- PLATO CON ZOCALO (base de las dos piezas siguientes) ----------
   Plato contra la cama y zocalo ciego con boca hacia arriba. */
module plato_zocalo(
    d_plato     = 140,
    esp         = 5,
    cono        = true,
    alto_cono   = 18,
    extra_cono  = 28,
    borde       = 0,
    pared_borde = 2.4,
    largo       = 70,
    profundidad = 55,
    goma        = true,
    d_goma      = 70,
    prof_goma   = 1.5
) {
    difference() {
        union() {
            vertical() cuerpo_flex(largo);
            cylinder(r = d_plato / 2, h = esp, $fn = 96);
            if (cono)                                  // 38 grados de la vertical: sin soporte
                translate([0, 0, esp - 0.01]) cylinder(d1 = _g + extra_cono, d2 = _g, h = alto_cono, $fn = 64);
            if (borde > 0)
                difference() {
                    cylinder(r = d_plato / 2, h = borde, $fn = 96);
                    translate([0, 0, -1]) cylinder(r = d_plato / 2 - pared_borde, h = borde + 2, $fn = 96);
                }
        }
        vertical() agujero_flex_ciego(largo, profundidad, largo_flex = _palo_largo_flex);
        if (goma) translate([0, 0, -1]) cylinder(d = d_goma, h = prof_goma + 1, $fn = 48);
    }
}

/* ---------- BASE ----------
   Para pararse en el piso: disco, cono de refuerzo y rebaje para goma antideslizante.
   PRUEBAS: diametro del disco segun la estabilidad; la goma. */
module base_flex(d_base = 140) {
    plato_zocalo(d_plato = d_base, cono = true, goma = true);
}

/* ---------- TAPA CON PLATO ----------
   Plato para el extremo superior de un palo (posavasos, bandeja pequeña, soporte).
   Se imprime con el plato contra la cama y se usa AL REVES: boca hacia abajo,
   plato arriba.
   PRUEBAS: que el agarre sostenga el plato con la carga prevista. */
module tapa_plato(d_plato = 130, borde = 14) {
    plato_zocalo(d_plato = d_plato, cono = false, goma = false, borde = borde, largo = 60, profundidad = 48);
}

/* ============================================================
   DEMO
   ============================================================ */

manguito_tope();

translate([130, 0, 0]) hub_cruce();

translate([260, 0, 0]) brazo_estante();

translate([440, 0, 0]) multi_gancho();

translate([0, 200, 0]) base_flex();

translate([180, 200, 0]) tapa_plato();

translate([0, 450, 0]) bandeja();

translate([260, 450, 0]) canasto();
