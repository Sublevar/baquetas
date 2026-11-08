include <config.scad>
use <hueco_baqueta.scad>
use <utils/acople.scad>

/* ============================================================
   MUEBLES CON TORNILLO DE PRESION
   Piezas para armar estantes, cajones y paneles entre 4 palos de escoba
   verticales (las esquinas de un rectangulo). Cada pieza es un collar que
   se prensa al palo con el tornillo de presion (mismo hueco, tuerca y
   avellanado que apoyos.scad) y lleva una repisa o guia.

     esquinero_tabla : repisa de esquina; 4 de ellas sostienen una tabla
                       entera entre los 4 palos (la tabla lleva las
                       esquinas recortadas, ver `muesca_tabla`)
     guia_cajon      : riel en L; 4 guias (2 por lado) forman las correderas
                       de un cajon cuyos costados apoyan en el riel
     bolsillo_panel  : canal en U donde entra el canto de una tabla que
                       queda de pie entre dos palos (fondo, lateral)

   Todas son un collar vertical (eje Z, el palo lo atraviesa) con el eje del
   palo en el origen. `az` gira la pieza alrededor del palo.
   El tornillo de presion sale siempre del lado opuesto a la repisa.
   Mira la propuesta y las cuentas de medidas en investigaciones/propuesta_muebles.md
   ============================================================ */

_d_fij   = 4.5;   // tornillo para madera (mm)
_d_cab   = 9;
_holg_tabla = 1;  // juego de la tabla dentro de las piezas (mm)

// collar vertical con hueco pasante y tornillo de presion (-X)
module _collar_cuerpo(alto, g, poly_n = _poly_n)
    rotate([0, -90, 0])
        acople_cuerpo(largo = alto, diametro = _diametro, holgura = _holgura, poly_n = poly_n,
            familia_tuerca = _familia_tuerca, subtipo_tuerca = _subtipo_tuerca,
            medida_tornillo = _medida_tornillo);

module _collar_hueco(alto, posiciones = [0.25, 0.75])
    rotate([0, -90, 0])
        acople_hueco(largo = alto + 1, profundidad_hueco = alto + 2,
            cantidad_tornillos = 1, posiciones = posiciones, angulo_tornillo = 0,
            profundidad_pieza = _profundidad,
            diametro = _diametro, holgura = _holgura, poly_n = _poly_n,
            familia_tuerca = _familia_tuerca, subtipo_tuerca = _subtipo_tuerca,
            medida_tornillo = _medida_tornillo);

/* Radio del recorte de esquina que hay que hacerle a la tabla para que
   rodee el collar (se imprime en el echo de esquinero_tabla). */
function muesca_tabla(g = grosor_baqueta(_diametro, _holgura, _familia_tuerca, _subtipo_tuerca, _medida_tornillo))
    = g / 2 + _holg_tabla;

/* ---------- ESQUINERO TRIANGULAR PARA TABLA ----------
   Placa en forma de TRIANGULO RECTANGULO ISOSCELES: el angulo recto queda
   sobre el eje del palo y los dos catetos (`cateto` mm) corren sobre los bordes
   de la tabla, hacia +X y +Y en el marco local; `az` = direccion de la bisectriz
   hacia el centro de la tabla (45, 135, 225, 315 segun la esquina).
   El vertice recto queda enterrado en la pared del collar (queda soldado a el)
   y el hueco del palo se resta DESPUES de unir la placa, asi la esquina no
   invade el hueco. El tornillo de presion sale hacia el lado opuesto (az + 180).
   Sin cantos, labios ni cartelas: placa plana con TRES agujeros avellanados
   (dos junto a los extremos de los catetos y uno hacia la hipotenusa) para
   atornillar la tabla desde abajo. El tamano de la tabla lo da la distancia
   entre palos; la tabla va recortada en cada esquina (ver muesca_tabla()).
   Para IMPRIMIR: placa contra la cama, collar hacia arriba (piezas.scad ya la da vuelta). */
module esquinero_tabla(
    az          = 45,
    alto        = 50,
    cateto      = 110,      // largo de cada cateto desde el eje del palo
    espesor     = 8,
    redondeo    = 4
) {
    g = grosor_baqueta(_diametro, _holgura, _familia_tuerca, _subtipo_tuerca, _medida_tornillo);
    echo(str("esquinero_tabla: recortar en cada esquina de la tabla un arco de radio >= ",
             muesca_tabla(g), " mm alrededor del palo"));
    z0 = alto - espesor;
    // agujeros (marco del cuadrante: catetos sobre +X y +Y)
    huecos = [[0.78 * cateto, 0.14 * cateto], [0.14 * cateto, 0.78 * cateto],
              [0.36 * cateto, 0.36 * cateto]];
    // el cuadrante se gira 45 grados para que la bisectriz quede sobre +X
    rotate([0, 0, az]) difference() {
        union() {
            _collar_cuerpo(alto, g);
            rotate([0, 0, -45]) translate([0, 0, z0]) linear_extrude(height = espesor)
                offset(r = redondeo) offset(delta = -redondeo)
                    polygon([[0, 0], [cateto, 0], [0, cateto]]);
        }
        _collar_hueco(alto);
        rotate([0, 0, -45]) for (p = huecos)
            translate([p[0], p[1], z0]) {
                translate([0, 0, -1]) cylinder(d = _d_fij, h = espesor + 2, $fn = 20);
                translate([0, 0, -1]) cylinder(d = _d_cab, h = espesor / 2, $fn = 20);
            }
    }
}

/* ---------- GUIA DE CAJON ----------
   Riel en L que sale del palo hacia +X (az gira). El costado del cajon
   (tabla de `espesor_costado`) apoya sobre la repisa y queda guiado por la
   pared del lado `lado_guia` (+1 / -1 en Y). Pegar dos guias por lado, una
   desde el palo delantero y otra desde el trasero, o una sola larga. */
module guia_cajon(
    az              = 0,
    alto            = 50,
    largo           = 160,       // desde el eje del palo
    ancho_repisa    = 22,        // lo que apoya del costado del cajon
    espesor         = 8,
    alto_pared      = 0,         // pared guia sobre la repisa (0 = sin canto; ej. 18)
    espesor_pared   = 5,
    lado_guia       = 1,         // +1: pared hacia +Y, -1: hacia -Y
    refuerzo        = false
) {
    g = grosor_baqueta(_diametro, _holgura, _familia_tuerca, _subtipo_tuerca, _medida_tornillo);
    z0 = alto - espesor;
    rotate([0, 0, az]) {
        difference() {
            union() {
                _collar_cuerpo(alto, g);
                translate([0, -ancho_repisa / 2, z0]) cube([largo, ancho_repisa, espesor]);
                if (alto_pared > 0)
                    translate([0, lado_guia * ancho_repisa / 2 - (lado_guia > 0 ? espesor_pared : 0), z0])
                        cube([largo, espesor_pared, espesor + alto_pared]);
                if (refuerzo)
                    translate([0, 0, z0]) rotate([90, 0, 0])
                        linear_extrude(height = 6, center = true)
                            polygon([[0, 0], [largo * 0.5, 0], [g / 2 - 1, -(alto - espesor) * 0.7], [0, -(alto - espesor) * 0.7]]);
            }
            _collar_hueco(alto);
            // avellanado para atornillar el costado desde abajo
            for (x = [largo * 0.5, largo * 0.85])
                translate([x, 0, z0]) {
                    translate([0, 0, -1]) cylinder(d = _d_fij, h = espesor + 2, $fn = 20);
                    translate([0, 0, -1]) cylinder(d = _d_cab, h = espesor / 2, $fn = 20);
                }
        }
    }
}

/* ---------- BOLSILLO PARA PANEL ----------
   Canal en U abierto hacia arriba donde entra el canto de una tabla de pie.
   Dos bolsillos enfrentados (uno por palo) sujetan un panel entre ellos.
   espesor_tabla: espesor real de la madera (se suma _holg_tabla). */
module bolsillo_panel(
    az              = 0,
    alto            = 60,
    espesor_tabla   = 18,
    profundidad     = 25,        // cuanto entra el canto en el canal (en X)
    pared           = 4,
    alto_canal      = 40
) {
    g = grosor_baqueta(_diametro, _holgura, _familia_tuerca, _subtipo_tuerca, _medida_tornillo);
    w = espesor_tabla + _holg_tabla;
    z0 = alto - alto_canal;
    rotate([0, 0, az]) {
        difference() {
            union() {
                _collar_cuerpo(alto, g);
                translate([0, -(w / 2 + pared), z0])
                    cube([g / 2 + profundidad, w + 2 * pared, alto_canal]);
            }
            _collar_hueco(alto);
            // ranura del canto: arranca fuera del collar, hacia arriba
            translate([g / 2, -w / 2, z0 + pared]) cube([profundidad + 1, w, alto_canal]);
        }
    }
}

/* ============================================================
   DEMO
   ============================================================ */
esquinero_tabla(az = 45);
translate([0, 160, 0]) guia_cajon();
translate([220, 0, 0]) bolsillo_panel();
