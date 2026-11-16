# Pendientes y advertencias

Estado: todo compila en OpenSCAD pero **nada esta probado impreso**.

## Muebles (`muebles.scad`)
- **Alta probabilidad de que se rompan.** Las placas planas de `esquinero_tabla`, `guia_cajon`
  y `bolsillo_panel` salen de un collar con una placa en voladizo de 8 mm; la union placa-collar
  es donde van a fallar (y las capas quedan en el sentido peor al imprimir de pie).
- **A agregar: un triangulo a modo de L (refuerzo/cartela)** bajo cada placa, entre el collar y
  la placa, para trabajar a compresion y no solo a flexion. Antes habia una cartela (se saco al
  quitar los cantos); hay que volver a ponerla como triangulo en L, **sin cantos laterales**,
  y definir si se imprime de pie o con la placa en la cama.
- Los tornillos de presion tambien pueden deslizar bajo carga (ver `propuesta_muebles.md`):
  segundo tornillo o tope inferior.

## Hirth (`hirth.scad`, un solo script, `junta_hirth(modo = ...)`)
- Modos hechos: `tope` (original), `cilindros` (palos libres solo 150-210 grados) y
  `cilindros_90` (libres desde 90 grados, recortando los flancos del hull con `r_corte = radio + 10`).
  El valor `radio + 10` se midio solo con los valores por defecto (R30, 24 dientes, `pico04`);
  verificar con `pico08`, otros radios y otros numeros de dientes.
- **A realizar: variante de cilindros con alto = diametro del acople.** Hoy el cilindro mide el
  radio del acople (g/2) y el eje del palo cae a la altura de los dientes. La variante con el
  cilindro del alto del diametro (g) queda pendiente de disenar y comparar.
- **A realizar: hirths con angulos "al punto de los dientes".** Anotado tal cual; interpretacion
  a confirmar: que los angulos posibles de la junta (y su rango libre) queden definidos y
  calculados en funcion del paso de los dientes (360/n_dientes), con la tabla de pasos libres
  informada por la propia pieza, en vez de medirlos a mano.
- **Nuevos (sin probar, solo compilan): `cilindros_calado`, `cilindros_inv` y `plano`.**
  - `plano` es la ex `hirth_plano.scad` (archivo borrado, migrado a `hirth.scad`). Se arreglo el
    tornillo central: antes el hull disco-palo tapaba la tuerca y la cabeza. Ahora se resta despues
    del hull (`hirth_tornillo_central`), con `asiento = "eje"` (canal desde abajo hasta el eje del
    palo) o `"pasante"` (pie plano abajo, tornillo de unos 100 mm).
  - `cilindros_inv`: los dientes van en la cara plana y cada palo queda de su lado del plano de
    union (giro libre en 360). Es `hirth_plano_mitad` con base = g/2.
  - `cilindros_calado`: tope en V invertida (o `forma_tope = "media_cana"`) a `d_tope` del eje.
    La cuenta es theta_min = 2*atan(w/d), con w = g/2 + luz_tope (para angulos chicos da ~2w/d rad).
    Con `d_tope = 0` sale de `angulo_min` (45). Matematica en `hirth_tope_calado.md`. **Verificar con `vista = "choque"` en
    `pasos = k_min`** (tiene que salir vacia): la cuenta toma el palo como franja de ancho 2w y
    deja aparte el flanco del hull (que llega hasta d_tope). Con 45 grados el acople se alarga
    (largo = d_tope + profundidad del hueco).
- **Nuevo (sin probar, solo compila): ejes de los palos en el mismo plano (`alinear_ejes`).**
  Referencia z = 0 = plano medio de los dientes; B es A volteada, asi que el desfase entre ejes
  es 2*|z_c|. `tope`: ahora por defecto z_c = 0 y el tope crece a max(alto_tope, g/2) (antes el
  desfase era 2*(alto_tope - g/2)); cambia la geometria de `hirth_A/B` y el largo del tornillo
  central. Cilindros: ya tenian z_c = 0. `cilindros_inv`/`plano`: opcional (`hirth_inv_al_A/B`),
  fuerza asiento pasante y niega los dientes con r_corte = radio + 10 como `cilindros_90`, asi que
  se pierde el giro libre en 360. **Verificar `vista = "choque"`** en tope (pasos 6) y en inv
  alineado (pasos 6 = 90 grados): tiene que salir vacia.
## Compilacion
- `build.sh` funciona en Linux/Docker/CI (usa `openscad` del PATH; la ruta de macOS es solo un
  respaldo). `Dockerfile` y `.github/workflows/build.yml` agregados, **sin ejecutar en GitHub**.
