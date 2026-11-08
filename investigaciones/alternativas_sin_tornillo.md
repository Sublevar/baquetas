# Alternativas al sistema: acoples deslizables sin tornillo

Estado: la linea principal del proyecto sigue siendo el acople con tornillo de presion
+ tuerca (`acople_cuerpo` / `acople_hueco`). Este documento deja anotadas las otras
opciones para piezas que se deslicen o se traben sin tornillo.
**Implementado:** la seccion 6 (brazos tangenciales flexibles para palos de 22 a 24 mm
no simetricos, `sin_tornillo.scad`). **Solo investigado:** el resto (secciones 2 a 5).

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
| 2 | Collar de tope partido con cuña | Locking sleeve | `acople_diagonal` / `apoyo_estante` sin brazos (hecho: `manguito_tope`) |
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

## 6. Implementado: palos de escoba de diametro variable (`sin_tornillo.scad`)

Requisito: palos de **22 a 24 mm** y, ademas, **no del todo simetricos**. Un hueco rigido
no sirve: o sobra juego en el palo fino o no entra el grueso. Hay que dejar que la pieza
ceda segun el diametro local.

### Que dicen las fuentes
- **[fuente]** Un taco de madera comercial varia unos ±1/64" (~0.4 mm) y la ovalidad no
  suele estar especificada; hay reportes de tacos ovalados por mas de 2 mm. Un palo de
  escoba es peor que un taco. Por eso el diseño cubre el nominal **mas** una ovalidad.
- **[fuente]** Las guias de snap-fit indican que un voladizo que flexa en Z (a traves de las
  capas) pierde ~50 % de elongacion y 20-30 % de resistencia, y que conviene reducir el
  limite de deformacion a la mitad en ese caso. (Dato tomado de un resumen de busqueda de
  las guias tipo core77/Fictiv; no verificado en la pagina original.)
- **[fuente]** Las flexiones tipo pinza permiten ajustes firmes sobre varillas, y el
  centrado a 3 puntos es la solucion clasica para elementos irregulares.

### Decision de diseño [propuesta]
**Tres brazos tangenciales** (viga curva en voladizo) dentro de una camisa, cada uno con un
resalte redondo en la punta que sobresale hacia el centro:
- Cada brazo cede **por su cuenta**: copia el diametro local aunque el palo sea ovalado
  (con el palo ovalado de 22 x 24 el material desplazado queda entre el del palo de 22 y
  el de 24, ver mediciones).
- Los brazos flexan **dentro del plano de capa** si se imprime con el eje vertical y la boca
  hacia arriba: la flexion no carga las capas en Z.
- 3 brazos = centrado estable a 3 puntos y brazos largos (23 mm de arco). Con 4 o mas
  la deformacion supera el limite supuesto (2.5 % con 4, 4.8 % con 5).
- Un tope fisico (la camisa) limita cuanto puede ceder el brazo, asi un palo demasiado
  grueso no lo sobreestira de forma indefinida.

### Parametros
| Parametro | Valor | Efecto |
|---|---|---|
| `d_min`, `d_max` | 22, 24 mm | rango nominal del palo |
| `ovalidad` | 0.5 mm | margen a cada lado para palos no simetricos (rango de diseño 21.5-24.5) |
| `precarga` | 0.3 mm | apriete radial sobre el palo mas fino; sube el agarre y la fuerza minima |
| `n_brazos` | 3 | cantidad de brazos |
| `espesor_brazo` | 2.4 mm | 3 lineas de un pico 0.8; con pico 0.4 se puede bajar a 1.6 |
| `largo_flex` | 30 mm | ancho del brazo = largo de la zona flexible |
| `ancho_ranura` | 1.6 mm | separa la punta de un brazo del poste siguiente |

`./calcular.sh flexible d_min=22 d_max=24 ovalidad=0.5 precarga=0.3` informa flecha,
deformacion en la raiz, fuerza y agarre estimados, y avisa si se pasan los limites.

### Piezas (`./build.sh` → `stl/<perfil>/sin_tornillo/`)
`acople` (ciego), `collar_deslizante` (pasante, zona flexible en cada extremo), `tapon`,
`cuna_ajuste`, `calibre_palo` y `prueba_agarre`. Todas salen de pie, boca hacia arriba.

### Resultados de las verificaciones geometricas
- Con el palo mas grueso (24.5 mm) el resalte se hunde 1.8 mm y el brazo, girado como solido
  rigido hasta tocar el palo, queda a **0.59 mm de la camisa**: cabe dentro del alojamiento.
- Material que desplaza el palo simulado: 21.0 mm → 1.5 mm³; 21.5 → 29; 22 → 74; 24 → 350;
  24.5 → 435. Progresivo; con 21.0 no toca (por debajo del rango de diseño).
- Estimaciones (supuestos E = 2000 N/mm², mu = 0.3): deformacion en la raiz **1.2 %** con el
  palo mas grueso (limite supuesto 2 %); agarre axial **4.5 N** con el mas fino y **26.9 N**
  con el mas grueso (relacion 6:1).

### Limitaciones conocidas (leer antes de confiar)
1. **Nada de esto esta probado impreso.** Fuerzas y limite de deformacion son supuestos;
   el modulo de elasticidad efectivo del PETG impreso puede estar muy lejos de la hoja de datos.
2. **Agarre bajo con el palo mas fino**: ~4.5 N alcanza para ganchos y topes livianos,
   no para una pata que cargue peso. Subir `precarga` o usar la cuña de ajuste.
3. El brazo esta unido al piso del alojamiento por su canto inferior, y eso lo vuelve mas
   rigido que la viga recta del calculo (el agarre real puede ser mayor, y la flecha
   efectiva menor). Corregir con la prueba.
4. **Solo con eje vertical**: si el acople va inclinado dentro de otra pieza (diagonal, trípode)
   el plano de flexion ya no coincide con las capas y se pierde la ventaja.
5. La **cuña de ajuste** es una ayuda sin validar; el **collet cónico** con anillo roscado
   no se implemento.
6. Los perfiles `pico04`/`pico08` solo cambian el diametro exterior del cuerpo: el rango del
   palo y la precarga se fijan con parametros, no con la holgura.

### Protocolo de prueba (hacerlo antes de usarlo)
1. Medir el palo real en 3 puntos con `calibre_palo` (pasa / no pasa) y girarlo para ver la ovalidad.
2. Imprimir `prueba_agarre` (4 precargas, 1 a 4 muescas) y probar el palo mas fino y el mas grueso:
   elegir la mas floja que aun agarra el fino y que el grueso entra sin forzar.
3. Con esa precarga, subir `largo_flex` o `n_brazos` solo si el calculo lo permite.
4. Despues del uso repetido (50 ciclos), revisar fisuras en la raiz de los brazos.

## 7. Implementado: familia de elementos al estilo CHOIS (`elementos_flex.scad`)

Piezas armadas sobre los brazos flexibles de la seccion 6. Se imprimen de pie, con la boca
del palo hacia arriba y el plato o la brida contra la cama. Los parametros del palo estan
en `config.scad` (`_palo_*`); los puntos a revisar tras imprimir estan marcados como
`PRUEBAS:` dentro del archivo.

| Pieza | Equivale a (CHOIS) | Huella x alto (mm) | Estado |
|---|---|---|---|
| `manguito_tope` | Locking sleeve | 60 x 60 x 60 | sin probar |
| `hub_cruce` | Hanger Bar Hub | 46 x 75 x 46 | geometria verificada; sin probar impresa |
| `bandeja` | Round Tray | 200 x 200 x 70 | sin probar |
| `canasto` | (inner tray / canasto) | 190 x 190 x 95 | sin probar |
| `brazo_estante` | brazo / estante | 153 x 50 x 110 | sin probar |
| `multi_gancho` | Multi Hook | 96 x 107 x 113 | sin probar |
| `base_flex` | Mini Base | 140 x 140 x 70 | sin probar |
| `tapa_plato` | Top Cap | 130 x 130 x 60 | sin probar |

### Como se arma (igual que el Hanger Bar)
1. Deslizar un `manguito_tope` por el pilar y dejarlo a la altura del hub.
2. Colocar el `hub_cruce` sobre el pilar, apoyado en el manguito; pasar la barra por el otro agujero.
3. Deslizar un manguito a cada lado del hub sobre la barra y poner un `tapon_flexible` en cada extremo.

El hub no sujeta nada por si mismo: tiene agujeros sueltos (juego `_holgura_hub`, 0.8 mm)
y son los manguitos los que frenan los palos. Verificado: palos de hasta 25 mm pasan
sueltos por los dos agujeros y queda pared entre ellos.

### Pendiente de probar (checklist)
- [ ] Agarre del palo con `prueba_agarre` y ajustar `_palo_*` en `config.scad`.
- [ ] `_holgura_hub`: ¿los palos entran justos pero sin forzar?
- [ ] Carga que aguanta cada pieza. El agarre por friccion estimado con el palo fino es de
      ~4.5 N: sirve para livianos; para cargas reales apoyar la pieza en un `manguito_tope`.
- [ ] `hub_cruce`: si la gota (punta a 45 grados) no alcanza para imprimir sin soporte.
- [ ] `canasto`: el borde alto (80 mm, 3.2 mm de pared) es la parte mas debil.
- [ ] `brazo_estante`: espesor de placa y cartela con el peso real de la tabla.
- [ ] `multi_gancho`: peso que aguantan las clavijas.

## Fuentes

- CHOIS Hanger Bar: https://thangs.com/designer/CraftedCycle/3d-model/CHOIS%20Hanger%20Bar-1616011
- Anuncio del Hanger Bar: https://thangs.com/designer/CraftedCycle/post/New:%20CHOIS%20Hanger%20Bar-255246
- CHOIS Valet Stand Starter Kit: https://thangs.com/designer/CraftedCycle/3d-model/CHOIS%20Valet%20Stand%20Starter%20Kit-1577609
- CraftedCycle: https://craftedcycle.com/ y https://thangs.com/designer/CraftedCycle
- Guia de snap-fit 3D: https://www.unionfab.com/blog/2025/06/3d-print-snap-fit
- Snap-fit joints (clips): https://www.sovol3d.com/blogs/news/3d-printed-snap-fit-joints-how-to-design-clips-that-work
- Tacos de madera, tolerancias: https://www.mcmaster.com/wood-dowel-rods/ y https://www.woodcraft.com/products/oak-dowel-1-round (resumen de busqueda)
- Mecanismos compliantes impresos: https://all3dp.com/2/compliant-mechanisms-3d-print/
- Flexiones tipo pinza sobre varillas: https://arxiv.org/pdf/2605.00853
- Mecanismo autocentrante de 3 brazos: https://image-ppubs.uspto.gov/dirsearch-public/print/downloadPdf/9442349
- Snap-fit en 3D (orientacion de capas): https://www.core77.com/posts/65318/How-to-Design-Snap-Fit-Components
