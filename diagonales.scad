include <config.scad>
use <hueco_baqueta.scad>
use <utils/acople.scad>
use <utils/trigonometria.scad>

/* ============================================================
   ACOPLES DIAGONALES Y BRAZOS
   Un collar vertical (eje Z, el poste lo atraviesa) con uno o mas
   huecos ciegos que salen en diagonal. Con angulo = 90 es un brazo
   horizontal. El nodo (cruce de ejes) queda en el origen.

   angulo   : entre el eje del poste (+Z, hacia arriba) y la diagonal
                 45  -> diagonal hacia arriba y afuera
                 90  -> brazo horizontal
                 135 -> diagonal hacia abajo y afuera
   azimuts  : lista de giros alrededor del poste, uno por diagonal
                 [0]        una diagonal
                 [0, 180]   dos opuestas (V / cruz de un lado)
                 [0, 90]    esquinero

   distancia_pieza: distancia nodo -> boca de cada diagonal. 0 = usar el
   minimo calculado (utils/trigonometria.scad): el mayor entre
     - boca_libre: la pared exterior de la diagonal se separa del poste
     - fondo_minimo + profundidad: el hueco no toca el hueco del poste
   Si se pide una distancia menor, se avisa con un echo y se construye igual.

   Tornillos de presion: por defecto dos, opuestos y A LOS COSTADOS (perpendiculares
   al plano que forman el poste y la diagonal), tanto en el collar como en el hueco
   de cada diagonal. Con cantidad_tornillos = 1 queda uno solo, de un costado.
   En el collar la orientacion y la altura se eligen solas para no atravesar el
   manguito de ninguna diagonal (ambas se pueden fijar a mano):
     - angulo_tornillo_collar = undef: gira hacia los azimuts mas alejados de
       todas las diagonales. Con [0] y [0,180] salen hacia 90 y 270; con [0,90]
       hacia 45 y 225.
     - posicion_tornillo_collar = undef: se aleja del nodo a lo largo del
       collar (0 = extremo inferior, 1 = superior): a 10 mm del extremo de
       abajo si las diagonales suben, del de arriba si bajan. Medido por
       interseccion: con el tornillo en el nodo el manguito quedaba cortado
       hasta ~280 mm3; asi queda en 0.

   Collar: si la diagonal esta a 55 grados o menos del poste, su manguito sigue
   pegado al collar hasta `boca_libre`. El collar llega hasta ahi (mas 8 mm);
   antes era fijo de 70 mm y el manguito asomaba por el borde, atravesado por el
   hueco del poste.

   La varilla se corta apoyada en el fondo: ver calculadora.scad.
   ============================================================ */

// distancia angular entre dos azimuts (0..180)
function dist_azimut(a, b) = let(d = abs(a - b) % 360) d > 180 ? 360 - d : d;

// azimut del primer tornillo del collar (multiplo de 15) para n tornillos
// equiespaciados: maximiza la distancia de TODOS los tornillos a la diagonal mas
// cercana; a igualdad, el mas cercano al opuesto de la primera diagonal
function mejor_azimut_tornillo(azimuts, n = 1) =
    let(cand  = [for (k = [0 : 24 / n - 1]) k * 15],
        score = [for (p = cand)
                    min([for (i = [0 : n - 1], a = azimuts) dist_azimut(p + i * 360 / n, a)])
                    - 0.001 * dist_azimut(p, azimuts[0] + 180)])
    cand[search(max(score), score)[0]];

// Mitades del collar por encima / por debajo del nodo. La diagonal sube (angulo < 90)
// o baja (> 90): su manguito sigue pegado al poste hasta `boca_libre` del nodo; si el
// collar termina antes, el manguito asoma por el borde y el hueco del poste lo atraviesa
// dejando una cuchilla. Por eso el lado hacia donde va la diagonal llega a boca_libre
// mas un margen. `alto_collar` > 0 fija un collar simetrico a mano.
function collar_arriba(g, angulo, alto_collar, minimo = 35, margen = 8) =
    alto_collar > 0 ? alto_collar / 2
                    : (angulo <= 90 ? max(minimo, boca_libre(g, angulo) + margen) : minimo);
function collar_abajo(g, angulo, alto_collar, minimo = 35, margen = 8) =
    alto_collar > 0 ? alto_collar / 2
                    : (angulo > 90 ? max(minimo, boca_libre(g, angulo) + margen) : minimo);

module acople_diagonal(
    angulo                 = 45,
    azimuts                = [0],
    alto_collar            = 0,      // 0 = automatico (ver collar_arriba / collar_abajo)
    distancia_pieza        = 0,
    profundidad_hueco      = 45,
    cantidad_tornillos     = 2,      // por collar y por diagonal, equiespaciados
    angulo_tornillo_collar = undef, // undef: automatico (lejos de todas las diagonales)
    posicion_tornillo_collar = undef, // 0..1 a lo largo del collar (0 = abajo); undef: automatico
    angulo_tornillo_diag   = 90,    // 90: a los costados del plano poste-diagonal
    profundidad_pieza      = _profundidad,
    pared                  = _pared_min,
    diametro               = _diametro,
    holgura                = _holgura,
    poly_n                 = _poly_n,
    familia_tuerca         = _familia_tuerca,
    subtipo_tuerca         = _subtipo_tuerca,
    medida_tornillo        = _medida_tornillo
) {
    g      = grosor_baqueta(diametro, holgura, familia_tuerca, subtipo_tuerca, medida_tornillo);
    r_h    = (diametro + holgura) / 2;
    fondo  = fondo_minimo(r_h, pared, angulo);
    boca_m = max(fondo + profundidad_hueco, boca_libre(g, angulo));
    boca   = distancia_pieza > 0 ? distancia_pieza : boca_m;
    // azimut del tornillo del collar -> giro sobre su eje (0 = azimut 180)
    a_col  = is_undef(angulo_tornillo_collar)
                 ? mejor_azimut_tornillo(azimuts, cantidad_tornillos) - 180
                 : angulo_tornillo_collar;
    arriba = collar_arriba(g, angulo, alto_collar);
    abajo  = collar_abajo(g, angulo, alto_collar);
    largo_c = arriba + abajo;
    // tornillo a 10 mm del extremo libre del collar (lado opuesto al que van las diagonales)
    p_col  = is_undef(posicion_tornillo_collar)
                 ? (angulo > 90 ? (largo_c - 10 + 1) / (largo_c + 2) : 11 / (largo_c + 2))
                 : posicion_tornillo_collar;

    // tornillos laterales: a menos de 75 grados entre diagonales, el de una toca a su vecina
    sep_min = len(azimuts) > 1
        ? min([for (i = [0 : len(azimuts) - 2], j = [i + 1 : len(azimuts) - 1]) dist_azimut(azimuts[i], azimuts[j])])
        : 360;
    if (sep_min < 75 && cantidad_tornillos > 1 && angulo_tornillo_diag == 90)
        echo(str("ADVERTENCIA acople_diagonal: diagonales a ", sep_min, " grados entre si; los tornillos ",
                 "laterales de una atraviesan a la vecina. Usar angulo_tornillo_diag = 0 o 180, ",
                 "cantidad_tornillos = 1, o separarlas 75 grados o mas"));

    if (boca < boca_m - 0.01)
        echo(str("ADVERTENCIA acople_diagonal: distancia_pieza=", boca,
                 " < minimo ", r1(boca_m), " mm (huecos muy cerca o diagonal pegada al poste)"));

    module marco_poste() translate([0, 0, -abajo]) rotate([0, -90, 0]) children();
    module marco_diag(az) rotate([0, 0, az]) rotate([0, angulo - 90, 0]) children();

    difference() {
        union() {
            marco_poste()
                acople_cuerpo(
                    largo = largo_c, diametro = diametro, holgura = holgura, poly_n = poly_n,
                    familia_tuerca = familia_tuerca, subtipo_tuerca = subtipo_tuerca,
                    medida_tornillo = medida_tornillo
                );
            for (az = azimuts) marco_diag(az)
                acople_cuerpo(
                    largo = boca, diametro = diametro, holgura = holgura, poly_n = poly_n,
                    familia_tuerca = familia_tuerca, subtipo_tuerca = subtipo_tuerca,
                    medida_tornillo = medida_tornillo
                );
        }
        // poste pasante + tornillo de presion
        marco_poste()
            acople_hueco(
                largo = largo_c + 1, profundidad_hueco = largo_c + 2,
                cantidad_tornillos = cantidad_tornillos, posiciones = [p_col], angulo_tornillo = a_col,
                profundidad_pieza = profundidad_pieza,
                diametro = diametro, holgura = holgura, poly_n = poly_n,
                familia_tuerca = familia_tuerca, subtipo_tuerca = subtipo_tuerca,
                medida_tornillo = medida_tornillo
            );
        // diagonales ciegas + tornillo de presion
        for (az = azimuts) marco_diag(az)
            acople_hueco(
                largo = boca, profundidad_hueco = profundidad_hueco,
                cantidad_tornillos = cantidad_tornillos, angulo_tornillo = angulo_tornillo_diag,
                profundidad_pieza = profundidad_pieza,
                diametro = diametro, holgura = holgura, poly_n = poly_n,
                familia_tuerca = familia_tuerca, subtipo_tuerca = subtipo_tuerca,
                medida_tornillo = medida_tornillo
            );
    }
}

/* Brazo horizontal: acople_diagonal con angulo = 90.
   azimuts: [0] un brazo, [0, 180] pasante, [0, 90] esquinero, [0, 120, 240] tres. */
module acople_brazo(azimuts = [0], distancia_pieza = 0) {
    acople_diagonal(angulo = 90, azimuts = azimuts, distancia_pieza = distancia_pieza);
}

/* ============================================================
   DEMO
   ============================================================ */

// Diagonal hacia arriba a 45 grados
acople_diagonal(angulo = 45);

// V: dos diagonales opuestas
translate([0, 200, 0]) acople_diagonal(angulo = 45, azimuts = [0, 180]);

// Diagonal hacia abajo (135)
translate([200, 0, 0]) acople_diagonal(angulo = 135);

// Brazo horizontal esquinero
translate([200, 200, 0]) acople_brazo(azimuts = [0, 90]);
