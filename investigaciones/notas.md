# Investigaciones

Ideas y codigo sacado de las piezas principales porque no se usaba todavia,
pero que conviene retomar. El codigo original completo sigue en el historial
de git (commit a6934fd).

## 1. `centrada` y `pasante` en `junta_angulo` (juntas.scad)

Parametros declarados en `junta_angulo` que **nunca se leyeron dentro del modulo**.
Parece que la idea era:

- `centrada`: centrar la junta respecto del origen (hoy el eje de giro queda en un extremo).
- `pasante`: que el hueco de la baqueta atraviese la junta en vez de ser ciego.

Codigo que se saco:

```scad
// globales
_centrada        = false;
_pasante         = false;

// parametros de junta_angulo
    centrada           = _centrada,
    pasante            = _pasante,
```

Pendiente: decidir si se implementan o no. `junta_angulo` tambien tiene el TODO
del avellanado (ver comentario `MEJORAR EL AVELLANADO` en el modulo).

## 2. Sagita (hueco_baqueta.scad)

Globales calculadas en el nivel superior de `hueco_baqueta.scad` que **nadie leia**
(el modulo `hueco_baqueta` recalcula su propia `sagita_` local, que si se usa
como `alivio` del bolsillo de tuerca):

```scad
d = diametro + holgura;
r = d / 2;

c = ancho_tuerca(familia_tuerca, subtipo_tuerca, medida_tornillo);
sagita = r - sqrt(pow(r, 2) - pow(c / 2, 2)) + holgura;

echo(str("Tuerca elegida: ", familia_tuerca, " / ", subtipo_tuerca, " ",
         medida_tornillo, " -> ancho llave: ", c));
```

Que es: la sagita es la flecha del arco que el hueco cilindrico de la baqueta deja
sobre el ancho de llave de la tuerca. Se pasa como `alivio` a `agujero_tuerca`, que
prolonga el bolsillo hexagonal esa profundidad hacia el eje (prisma hexagonal bajo
la tuerca, ver `utils/tuerca_UNC-UNF.scad`, parametro `alivio`), para que la tuerca
apoye sin chocar con la pared curva del hueco.

Pendiente: revisar si la formula es correcta cuando `holgura` cambia entre picos
(se suma `holgura` al final, pero `r` ya la incluye) y si conviene exponer el
valor como parametro en vez de recalcularlo.
Tambien hay un uso comentado en `utils/tuercas_metricas.scad` (lineas ~216-221).
