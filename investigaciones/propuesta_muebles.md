# Propuesta: muebles entre 4 palos con acoples de tornillo de presion

Estado: **geometria que compila (`muebles.scad`), nada impreso ni probado.**
Usa el mismo collar que `apoyos.scad` (hueco 24 + holgura, tuerca UNC 3/16, avellanado),
asi que hereda su exterior de 46.3 mm (47.3 con `pico08`) y el tornillo de presion.

## Montaje base: 4 palos como esquinas de un rectangulo

```
  P1 ────── P2          P = palo vertical, vista desde arriba
  │  tabla  │           la tabla llega hasta el eje de cada palo y lleva un
  P4 ────── P3          recorte de esquina de radio >= 24.2 mm (g/2 + 1)
```

Distancia entre centros de palos = medida de la tabla (sin restar nada); el recorte
alrededor del collar lo hace un serrucho de calar o una sierra copa. `esquinero_tabla`
imprime en consola el radio minimo (`muesca_tabla`).

## Piezas

| Pieza (`muebles.scad`) | Para que sirve | Cantidad por nivel | Comentario |
|---|---|---|---|
| `esquinero_tabla(az)` | Estante: tabla entera apoyada en 4 repisas de esquina | 4 (az = 45, 135, 225, 315) | Cuadrante de 80 mm bajo la tabla, labio de tope, cartela, 2 agujeros para atornillar la tabla desde abajo |
| `guia_cajon(az, lado_guia)` | Correderas de un cajon: el costado apoya en la repisa del riel y la pared lo guia | 4 (2 por lado, delantera y trasera) o 2 largas | Largo 160 por defecto; el cajon corre sobre PETG, conviene cera/ vela en el riel |
| `bolsillo_panel(az)` | Tabla de pie entre dos palos (fondo, lateral, divisor) | 2 por panel | Canal en U de 18 + 1 mm, 25 mm de profundidad |

### Armados utiles
1. **Estante simple**: 4 `esquinero_tabla` a la misma altura. Se puede repetir a varias alturas con un unico juego de tablas.
2. **Mesa de arrime / escritorio**: igual, con un nivel a 700 mm; los `tripode`/`pata_base` existentes cierran el piso.
3. **Estante con fondo**: estante + 2 `bolsillo_panel` por palos traseros y una tabla de fondo.
4. **Cajon**: 4 `guia_cajon` (az = 0 desde los palos delanteros hacia atras, az = 180 desde los traseros hacia adelante, o una larga por lado) + caja de madera con costados de 15-18 mm. Los costados apoyan 22 mm sobre el riel; la pared de 18 mm evita que el cajon se desvie.
5. **Estante esquinero/mesa baja**: `esquinero_tabla` con `lado` menor (60) para ahorrar filamento si la tabla es chica.

## Cuentas y supuestos

- Una `esquinero_tabla` con repisa de 8 mm y cartela: la carga se transmite al palo por friccion del
  tornillo de presion (no por el collar). **Un estante cargado con 4 tornillos de presion de 3/16 puede deslizarse
  en un palo liso**; hay que decidir antes de imprimir si se acepta (cargas livianas), si se agrega una
  segunda tuerca (`cantidad_tornillos = 2`) o se apoya el collar sobre un anillo/tope inferior (ver
  `manguito_tope` en `elementos_flex.scad`). **[propuesta, sin calcular]**
- Todos los collares tienen el tornillo hacia el lado opuesto de la repisa/guia, igual que `apoyo_estante`.
- Con `pico08` el exterior sube 1.0 mm y la pared de las guias/bolsillos (4-5 mm) son multiplos de la linea (0.8).

## Probar primero (orden)
- [ ] Imprimir un solo `esquinero_tabla` y verificar si se mantiene con una tabla de 400 x 400 sin deslizar.
- [ ] Medir real de la tabla (espesor, escuadra) y ajustar el recorte de esquina.
- [ ] `guia_cajon`: friccion del costado sobre PETG; probar sin y con cera.
- [ ] `bolsillo_panel`: que el canal admita la tabla sin forzar (`_holg_tabla`).
- [ ] Si deslizan: sumar tope inferior o segundo tornillo.

## Pendientes de diseno
- Una variante `esquinero_tabla` que **sostenga tabla de los dos lados** (estante pasante, `brazos = [az, az+180]`).
- `guia_cajon` con tope trasero para que el cajon no salga de la guia.
- Frente de cajon con tirador (o manija en la caja).
- Union entre dos `guia_cajon` y los dos `esquinero_tabla` de un mismo palo para compartir tornillo.

## Cambios de la segunda version (sin cantos, sin encastres)

Pensado para imprimir en 3D: se sacaron los labios/cantos laterales, las cartelas y todo el
sistema de nodos + rieles con cola de milano (quedaba complejo y debil). Se mantiene el tamano
libre porque **la tabla se corta a la medida y la pieza es siempre la misma**.

- `esquinero_tabla` ahora es una **placa triangular rectangula isosceles** (catetos de `cateto` = 110 mm sobre los bordes
  de la tabla; el angulo recto sobre el eje del palo, enterrado y soldado al collar; el hueco del palo se resta
  despues, asi la esquina no lo invade), sin ningun canto, con **3 agujeros avellanados**
  (dos junto a los extremos de los catetos y uno hacia la hipotenusa). Se imprime con la placa contra la cama (`piezas.scad` ya la da vuelta). Para una
  repisa de una sola esquina alcanza con subir `cateto` y `alto`; con 4 palos son 4 iguales.
- `guia_cajon` ya no lleva pared guia por defecto (`alto_pared = 0`; si se necesita, `alto_pared = 18`).
- `bolsillo_panel` conserva el canal porque es su funcion.
