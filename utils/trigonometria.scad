/* ============================================================
   TRIGONOMETRIA DE DIAGONALES Y TRIPODES
   Funciones puras (sin geometria) compartidas por diagonales.scad,
   tripodes.scad y calculadora.scad.

   Convenciones
     nodo      : punto donde se cruzan los ejes de dos varillas
     fondo     : distancia nodo -> fondo ciego del hueco, medida por el eje
                 de la varilla. La varilla se corta apoyada en el fondo.
     boca      : distancia nodo -> boca del hueco (= fondo + profundidad)
     phi, theta: angulos entre ejes, en grados
   ============================================================ */

// ---------- triangulo rectangulo ----------
function hipotenusa(a, b)         = sqrt(a * a + b * b);
function largo_por_coseno(ady, ang) = ady / cos(ang);   // hipotenusa = adyacente / cos
function largo_por_seno(op, ang)  = op / sin(ang);      // hipotenusa = opuesto / sen
function angulo_catetos(ady, op)  = atan2(op, ady);     // angulo medido desde el adyacente

// ---------- distancias minimas por diametro ----------
// Dos cilindros de radio g/2 que se cruzan con angulo phi entre ejes dejan de
// tocarse, por el lado agudo, a (g/2)/tan(phi/2) del nodo. Antes de eso la
// diagonal esta "pegada" al poste.
function boca_libre(g, phi) = (g / 2) / tan(min(phi, 180 - phi) / 2);

// Fondo minimo del hueco diagonal para que su pared quede a `pared` mm del
// hueco recto (pasante) del poste. phi = angulo entre eje del poste y diagonal.
function fondo_minimo(r_hueco, pared, phi) =
    (r_hueco * (1 + abs(cos(phi))) + pared) / sin(phi);

// Fondo minimo de las patas de un tripode (n patas, theta desde la vertical)
// para que los huecos de dos patas vecinas no se toquen.
function fondo_radial(r_hueco, pared, theta, n) =
    (2 * r_hueco + pared) / (2 * sin(theta) * sin(180 / n));

// Fondo minimo para que el borde del hueco inclinado (theta desde la vertical)
// quede `margen` mm por debajo (o por encima) de un plano horizontal que pasa
// por el nodo (o por el piso en la punta de la pata).
function fondo_sobre_plano(r_hueco, margen, theta) =
    (margen + r_hueco * sin(theta)) / cos(theta);

// ---------- varilla ----------
// Largo a cortar con la varilla apoyada en el fondo de los dos huecos.
function largo_corte(L_ejes, fondo_a, fondo_b) = L_ejes - fondo_a - fondo_b;

// Dos varillas que se cruzan (X) en planos paralelos: separacion minima entre
// sus ejes = diametro de la varilla + luz.
function desfase_cruz(diametro, luz = 2) = diametro + luz;

// redondeo para los informes
function r1(x) = round(x * 10) / 10;
