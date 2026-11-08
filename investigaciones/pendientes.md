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
- `hirth_plano.scad` aparece borrado del arbol de trabajo (no lo borre yo): las piezas
  `hirth_plana_*` se sacaron de `piezas.scad`/`build.sh`. Esta en git (`git show HEAD:hirth_plano.scad`).

## Compilacion
- `build.sh` funciona en Linux/Docker/CI (usa `openscad` del PATH; la ruta de macOS es solo un
  respaldo). `Dockerfile` y `.github/workflows/build.yml` agregados, **sin ejecutar en GitHub**.
