/* ============================================================
   FLEXION DE BRAZOS PARA ACOPLES SIN TORNILLO
   Funciones puras compartidas por sin_tornillo.scad y calculadora.scad.

   El acople sin tornillo sujeta el palo con brazos tangenciales
   flexibles (viga en voladizo curva, de espesor t radial y ancho b a lo
   largo del eje). Cada brazo lleva un resalte (tope) que sobresale hacia
   el centro; el resalte cede hacia afuera segun el diametro real del palo.

   Rango de diseño del palo (diametros):
     d_lo = d_min - ovalidad     el palo mas fino, en su punto mas chico
     d_hi = d_max + ovalidad     el palo mas grueso, en su punto mas grande
   La ovalidad cubre palos no simetricos: cada brazo cede por su cuenta,
   asi que el acople copia el diametro local.

   SUPUESTOS (sin validar con impresiones; calibrar con prueba_flexible):
     E_pet    : modulo de elasticidad efectivo del PETG impreso (N/mm2)
                El dato de hoja de datos (3.5 GPa) es optimista en FDM
     eps_max  : deformacion maxima admisible en la raiz del brazo,
                conservadora para ciclos repetidos
     mu       : coeficiente de friccion plastico-madera
   La viga recta subestima la rigidez real: el brazo esta unido al piso del
   alojamiento por su canto inferior, y eso lo endurece.
   ============================================================ */

E_pet   = 2000;   // N/mm2
eps_max = 0.02;   // 2 %
mu      = 0.3;

// ---------- viga en voladizo ----------
function inercia(b, t)                    = b * pow(t, 3) / 12;
function fuerza_brazo(b, t, L, delta, E = E_pet) = 3 * E * inercia(b, t) * delta / pow(L, 3);
// deformacion en la raiz con la flecha delta en la punta
function deformacion_brazo(t, L, delta)   = 3 * t * delta / (2 * L * L);
// largo minimo para no pasar eps con la flecha delta
function largo_brazo_min(t, delta, eps = eps_max) = sqrt(3 * t * delta / (2 * eps));

// ---------- geometria radial ----------
// Devuelve [r_tope, r_in, r_ext_brazo, delta_pre, delta_max, gap, r_alojamiento]
//   r_tope   : radio libre en reposo entre resaltes (menor que el palo mas fino)
//   r_in     : cara interior del brazo; el palo mas grueso pasa sin tocarla
//   delta_pre: flecha radial del resalte con el palo mas fino  (= precarga)
//   delta_max: flecha radial del resalte con el palo mas grueso
//   gap      : espacio libre detras del brazo para que ceda
function geom_flex(d_min, d_max, ovalidad, precarga, espesor, hol_int = 0.3, luz_gap = 0.6) =
    let(d_lo    = d_min - ovalidad,
        d_hi    = d_max + ovalidad,
        r_tope  = d_lo / 2 - precarga,
        r_in    = d_hi / 2 + hol_int,
        r_a     = r_in + espesor,
        d_max_r = d_hi / 2 - r_tope,
        gap     = d_max_r + luz_gap)
    [r_tope, r_in, r_a, precarga, d_max_r, gap, r_a + gap];

// longitud del brazo (arco libre desde el poste hasta la punta), n brazos
function largo_arco(r_med, n, ancho_poste, ancho_ranura) =
    r_med * (360 / n - (ancho_poste + ancho_ranura) / r_med * 180 / PI) * PI / 180;

// ---------- agarre ----------
// fuerza axial de agarre con n brazos y flecha delta (friccion)
function agarre(n, b, t, L, delta, E = E_pet, m = mu) = m * n * fuerza_brazo(b, t, L, delta, E);

