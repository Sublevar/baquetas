# Alternativas al sistema: acoples deslizables sin tornillo

Estado: **investigacion, nada implementado**. La linea principal del proyecto sigue
siendo el acople con tornillo de presion + tuerca (`acople_cuerpo` / `acople_hueco`).
Este documento deja anotadas las otras opciones para cuando se quiera ampliar a
piezas que se deslicen o se traben sin tornillo (palo de escoba, por ejemplo).

Convencion: **[fuente]** = dato tomado de las paginas consultadas (links al final).
**[propuesta]** = idea de diseño propia, sin probar. Los valores numericos de las
propuestas son puntos de partida, no tolerancias validadas.

## 1. Referencia: CHOIS Hanger Bar (CraftedCycle)

- **[fuente]** CHOIS = *Connective Hardware for Open Integrated Structures*: se imprimen
  las juntas, se compran varillas de madera de ferreteria y no hace falta pegamento ni tornillos.
- **[fuente]** El Hanger Bar convierte el pilar vertical de un Starter Kit en un perchero
  horizontal. Trae un **hub**, **3 locking sleeves** y **2 end caps**. Un sleeve asegura el
  pilar y dos agarran la barra horizontal; las tapas cierran los extremos y evitan que se corran las perchas.
- **[fuente]** Medidas de varilla: 30 mm y 32 mm (1-1/4"). No se mezclan piezas de los dos tamanos.
  El sistema base tambien menciona 1", 25 mm y 24 mm.
- **[fuente]** Traba por **ajuste de friccion**, con un **anillo de calibracion** que se imprime primero
  y cuñas ("tight wedge options for fine adjustment") para el ajuste fino.
- **[fuente]** Impresion: 4 perimetros, relleno 15 %, capa 0.20 mm; PETG o ABS recomendado
  para el Starter Kit (PLA alcanza para el Hanger Bar en interior).
- **No documentado en las paginas:** como funciona por dentro un locking sleeve, angulos de cuña,
  tolerancias. Lo que sigue no es una copia: son mecanismos genericos.

Familia de piezas CHOIS (para inspirar nuestras piezas): base joint, mini base conica,
multi hook, top cap, bandejas, soporte de celular, valet stand, mesa de sofa.

## 2. Mecanismos

Contexto de nuestras medidas: varilla de 24 mm, cuerpo exterior de 46.3 mm (47.3 con
holgura 1.5) porque hoy la tuerca manda el ancho. Sin tornillo el ancho exterior ya no
depende de la tuerca: se puede bajar, o conservar 46.3 mm para seguir siendo compatible
con las juntas actuales.

| # | Mecanismo | Desliza | Traba | Con pico 0.8 | Notas |
|---|---|---|---|---|---|
| A | Collar partido + cuña | si, aflojando | si, ajustable | si | Es lo mas parecido a un locking sleeve |
| B | Pinza en C (clip abierto) | a presion | friccion | si, para cargas livianas | Se pone de costado, sin pasar la varilla por el extremo |
| C | Nervios de interferencia | a presion | friccion | mejor con pico 0.4 | Tolera varillas no redondas |
| D | Collet conico + anillo roscado | si, aflojando | muy firme | roscas gruesas | Mas piezas, mas imprimible en PETG |
| E | Bayoneta / twist-lock | si | si | si | Hay que cuidar el voladizo del canal |
| F | Excentrica / leva | si, rapido | si | delicada | Pivote impreso en el lugar o con eje metalico |
| G | Clavija en perforacion | por posiciones | si | si | Exige perforar el palo |

### A. Collar partido + cuña **[propuesta]**
Una ranura longitudinal deja el collar flexible; una cuña conica o un aro lo cierra sobre la varilla.
- Parametros: ancho de ranura, angulo de la cuña (empezar suave, 5-8 grados, para que se auto-trabe), espesor de las paredes que flexan.
- Pico 0.8: paredes de flexion de 3 mm o mas (multiplo de la linea de 0.8).
- Riesgo: una sola pieza que flexa repetidas veces; imprimir en PETG con las capas a lo largo de la flexion.

### B. Pinza en C **[propuesta]**
Anillo abierto con boca algo menor que el diametro de la varilla y entrada con chaflan.
- **[fuente]** Chaflan de entrada de 20-30 grados, espesor minimo 1 mm en la base de la lengüeta, PETG para piezas que se abren muchas veces.
- Sirve para ganchos y perchas livianas; para carga real conviene el collar partido.

### C. Nervios de interferencia **[propuesta]**
3 o 4 costillas internas que se aplastan al insertar la varilla. El ajuste se regula con la altura de las costillas, no con el diametro del hueco, asi que tolera el palo de escoba (que no es perfectamente redondo ni constante).
- Pico 0.8: costillas de al menos una linea (0.8 mm) de ancho; con holgura 1.5 la friccion pura no agarra, usar A.

### D. Collet conico + anillo roscado **[propuesta]**
Casquillo con ranuras y un anillo roscado que lo comprime al apretar.
- Roscas impresas gruesas (paso 2-3 mm) con juego holgado.

### E. Bayoneta **[propuesta]**
Canal en L en la pieza y pasador en el collar. Util para tapas y topes que se sacan seguido.

### F. Excentrica **[propuesta]**
Leva que aprieta un collar partido. Rapida de operar, pero es la pieza mas fina de imprimir.

### G. Clavija en perforacion **[propuesta]**
Perforar el palo cada cierta distancia y trabar con un pasador. Un **trinquete (pawl) no sirve** en un palo liso: necesita dientes o perforaciones.

## 3. Reglas de diseno FDM (snap-fit y friccion)

**[fuente]** Guias de snap-fit en FDM:
- Lengüeta (cantilever) de espesor minimo 1 mm en la base y saliente de al menos 1 mm.
- Chaflan de entrada de 20-30 grados.
- Holgura minima de 0.2 mm por lado con pico 0.4; algunas guias indican 0.5 mm para conectores snap.
- PETG para uniones que se abren y cierran mas de una vez.
- Flexion: delta = F·L^3 / (3·E·I); modulo del PETG ~3.5 GPa; fuerza de insercion tipica 2-5 N.
- Las piezas FDM son anisotropas: orientar la lengüeta para que las capas corran a lo largo.

**[propuesta]**
- Con el perfil `pico08` (holgura radial 1.5 mm) la friccion fina no es viable. Para fricción usar un perfil con holgura menor, o imprimir esas piezas con pico 0.4.
- Imprimir primero un **anillo de calibracion** con holguras de 0.0 a 0.6 en pasos de 0.1 y medir el palo real en tres puntos antes de fijar el valor.

## 4. Piezas candidatas (inspiradas en CHOIS)

| # | Pieza | Equivale a | Reutiliza |
|---|---|---|---|
| 1 | Anillo / peine de calibracion | Calibration ring | `config.scad`, perfiles |
| 2 | Collar de tope partido con cuña | Locking sleeve | `acople_diagonal` / `apoyo_estante` sin brazos |
| 3 | Hub de cruce pasante | Hanger Bar Hub | `junta_T`, `acople_brazo` |
| 4 | Tapon a presion con nervios | End cap | `terminal` |
| 5 | Perchas y ganchos | Multi Hook | `apoyos.scad` |
| 6 | Tapa superior con plato | Top Cap | `apoyo_estante` |
| 7 | Base conica sin tornillos | Mini Base | `pata_base`, `punta_pata` |
| 8 | Ensamble de ejemplo | Valet Stand | `pie_tripode`, `junta_array` |

## 5. Como encajaria en el codigo (si se hace)

- Un modulo `acople_deslizante(modo = "tornillo" | "partido" | "friccion", ...)` en `utils/`, junto a `acople.scad`, con el mismo contrato (eje X, boca en `x = largo`).
- Un parametro para elegir entre ancho exterior heredado (46.3 mm) y ancho minimo.
- Nuevas columnas en `_perfiles` de `config.scad` para las holguras de deslizamiento y friccion por pico.
- Pruebas: anillo de calibracion primero, despues collar partido, despues el resto.

## Fuentes

- CHOIS Hanger Bar: https://thangs.com/designer/CraftedCycle/3d-model/CHOIS%20Hanger%20Bar-1616011
- Anuncio del Hanger Bar: https://thangs.com/designer/CraftedCycle/post/New:%20CHOIS%20Hanger%20Bar-255246
- CHOIS Valet Stand Starter Kit: https://thangs.com/designer/CraftedCycle/3d-model/CHOIS%20Valet%20Stand%20Starter%20Kit-1577609
- CraftedCycle: https://craftedcycle.com/ y https://thangs.com/designer/CraftedCycle
- Guia de snap-fit 3D: https://www.unionfab.com/blog/2025/06/3d-print-snap-fit
- Snap-fit joints (clips): https://www.sovol3d.com/blogs/news/3d-printed-snap-fit-joints-how-to-design-clips-that-work
