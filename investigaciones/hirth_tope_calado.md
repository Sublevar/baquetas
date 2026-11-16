# Hirth: tope calado (V invertida / media cana)

Matematica detras del modo `junta_hirth(modo = "cilindros_calado")` de `hirth.scad`
(`hirth_calado_w`, `hirth_calado_d`, `hirth_calado_theta`, `hirth_calado_corte`).

Estado: compila, **sin probar impreso** y sin verificar la `vista = "choque"`.

## Planteo (vista en planta, desde el eje Hirth)

- Palo de A a lo largo de +X; ocupa la franja |y| <= w.
- w = medio ancho del acople = g/2 + `luz_tope`
  (g = `grosor_baqueta(...)` = diametro del palo + holgura + armadura de las tuercas).
- El palo de B es la misma franja girada un angulo theta alrededor del eje Hirth.
- d = `d_tope` = distancia del eje Hirth al plano donde arranca el tope del acople.

## 1. Condicion de choque

Un punto (x, y) de A, llevado al marco de B (giro -theta), tiene coordenada lateral

    y_B = -x * sin(theta) + y * cos(theta)

y esta dentro del palo de B si |y_B| <= w. No choca si

    x * sin(theta) - y * cos(theta) > w
    x > (w + y * cos(theta)) / sin(theta)

B puede girar hacia los dos lados (+theta y -theta), asi que se toma |y|:

    x_corte(y) = (w + |y| * cos(theta)) / sin(theta)

Es lineal en |y|, por eso el borde del tope es una **V**:

| punto              | x                                         |
|--------------------|-------------------------------------------|
| punta (y = 0)      | w / sin(theta)  (lo mas cerca del eje)    |
| cantos (y = +-w)   | w (1 + cos(theta)) / sin(theta) = w * cot(theta/2) = d |

## 2. Angulo minimo

De d = w * cot(theta/2):

    theta_min = 2 * atan(w / d)          (exacta, radianes si atan da radianes)
    d         = w / tan(angulo_min / 2)  (al reves: lo que hace d_tope = 0)

**Aproximacion por perimetro** (la idea original): para angulos chicos
cot(theta/2) ~ 2/theta, entonces

    theta ~ 2w / d   [rad]

o sea, el arco recorrido a la distancia d, que es la fraccion del perimetro
2*PI*d * (theta / 2*PI) = theta * d, tiene que cubrir el ancho del palo, 2w.
La exacta corrige cuando el angulo crece: a 45 grados da 0.785 rad y la
aproximacion 0.828 rad.

**Pasos libres:** con paso = 360 / `_n_dientes` (config.scad),

    k_min = ceil(theta_min / paso)       (en el codigo con -1e-6 por redondeo)
    pasos libres: de k_min a n_dientes - k_min

Valores por defecto (pico04, angulo_min = 45, 24 dientes): w = 24.16 mm,
d = 58.34 mm, theta_min = 0.785 rad, pasos libres de 3 a 21.

## 3. Los lados de la V

Pendiente de cada lado, de la punta (w/sin theta, 0) al canto (d, w):

    dx = d - w/sin(theta) = w * cot(theta)
    dy = w
    dy/dx = tan(theta)

Cada lado forma **exactamente el angulo theta con el eje del palo**: es el borde del
palo de B en su posicion limite. El tope copia la silueta del palo vecino.

## 4. Media cana (`forma_tope = "media_cana"`)

En el codigo:

    offset(r = -w) offset(r = w) v();

Es un **cierre morfologico** del poligono de corte (primero se agranda el corte en w y
despues se achica en w con arcos):

- Donde el borde es recto, o el corte tiene un angulo saliente (los cantos en
  (d, +-w)), el borde queda igual.
- En la punta de la V el corte tiene un angulo entrante: se rellena con un **arco de
  radio w tangente a los dos lados**.

Geometria del circulo de radio r = w inscripto en un angulo de semiapertura theta:

    centro del arco:        x = w/sin(theta) + w/sin(theta) = 2w / sin(theta)
    punta redondeada:       x = w * (2 / sin(theta) - 1)
    tangencia sobre el lado: a w * cot(theta) de la punta
                             (el lado mide w / sin(theta): empalma antes del canto)

Con los valores por defecto: punta de la V en x = 34.2 mm, punta de la media cana en
x = 44.2 mm (unos 10 mm mas de material sacado en el centro).

**Por que es segura:** el cierre solo saca material respecto de la V, nunca agrega; si
la V no choca, la media cana tampoco. El radio w es el del acople, asi que la curva
acompana al palo.

## 5. Supuestos y limites

- **En planta:** el palo de B se toma como franja de ancho 2w a toda altura. En realidad
  es medio cilindro que se angosta con la altura: la cuenta es conservadora en ese sentido.
- **Flanco del hull:** cerca del disco el hull disco-palo es mas ancho que 2w. Por eso en
  el calado el hull llega solo hasta d; mas alla sigue el palo solo. Entre el disco y d el
  flanco no entra en la cuenta: verificarlo con `vista = "choque"` en `pasos = k_min`
  (tiene que salir vacia).
- **Angulos obtusos:** para theta > 90 grados cos(theta) < 0 y la punta queda mas alla de
  d (la V se da vuelta). La formula sigue valiendo, pero ahi conviene `cilindros_90`.
- El acople se alarga: largo = max(radio + largo_extra, d + profundidad del hueco), para
  que el corte no abra el hueco del palo.
- El `offset` no tiene `$fn` propio: el arco puede salir facetado.
