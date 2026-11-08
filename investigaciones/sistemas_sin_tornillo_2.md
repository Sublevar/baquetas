# Segunda ronda: sistemas sin tornillo, 100 % impresos, con palos de escoba

Complementa `alternativas_sin_tornillo.md` (que ya cubre CHOIS y los mecanismos A-G).
Metodo: busquedas web (6, nov 2026); **solo se leyeron resumenes de resultados, no las
paginas completas ni se valido la carga de ningun modelo.** **[fuente]** = lo dicen los
resultados; **[propuesta]** = idea propia sin probar.
Resultado honesto: **no aparecio un sistema 100 % impreso, sin tornillo, ya validado
para varilla de 22-24 mm.** Lo mas cercano son piezas de 10-12 mm o sistemas que igual usan un tornillo de madera.

## 1. Lo que existe

| Sistema | Que hace | Por que importa |
|---|---|---|
| CHOIS (Honami) | conectores impresos que sujetan varillas estandar con tolerancia, solo hay que cortar a ojo | referencia ya anotada |
| Parametric dowel and tube joiners (MakerWorld 2933746) | conector parametrico con **costillas de agarre opcionales** y tolerancia ajustable | refuerza la propuesta C (nervios de interferencia) |
| Silla press-fit (MakerWorld 1281823) | encaje a presion, pero su guia pide fijar con tornillo autorroscante | ejemplo de que la friccion pura se queda corta en cargas reales |
| Tension jack 15 mm (MakerWorld) | pie inferior + pie superior, gira un manguito y tensa entre mueble y techo | idea de **cierre por tension** (propuesta nueva H) |
| Collet con tuerca (Printables "DTI clamps") | collet partido comprimido por tuerca; el autor avisa que **la tuerca impresa es debil** | confirma el riesgo del mecanismo D |
| Collar de pesas roscado print-in-place (MakerWorld 2870508) | collar roscado impreso, probado por el autor "~85 kg" | evidencia de que una rosca impresa gruesa si aguanta (dato del autor, no verificado) |
| Collet parametrico (MakerWorld 2938039) | perfiles rigido/flexible | codigo reutilizable de referencia |
| Abrazadera angular con cuna impresa (MakerWorld 1684750) | cuna + rosca + traba, todo impreso | para la propuesta I (cuna con traba) |
| Cuñas de abrazadera CNC (foro Maslow) | cuñas de plastico fisuradas; el nylon SLS aguanta mas | **PETG/nailon, no PLA**, para piezas con cuña |
| Union de espiga cruzada (Fox & Giraffe, Sketchfab; CC BY-NC-SA) | traba por giro de 90 grados del palo, en madera | idea de bayoneta/giro (E) pero en la madera |
| Pasador y cuña de cola de milano (remix MakerWorld 2073394) | dos mitades que se unen con cuña tipo cola de milano + travesano que la bloquea | traba por **cuña + pasador** |
| Soporte de estante con varilla (stlfinder 1890768) | repisa de pared con varilla | otra manera de ver `esquinero_tabla` |
| Cam lock impreso estilo IKEA (Printables 1475817) | leva en agujero | mecanismo F listo para copiar |
| Abrazaderas con ratchet (MakerWorld 1911336, MyMiniFactory 89776) | cremallera impresa | base para el cierre H |
| Bridas sobre palo de 22 mm (MakerWorld 2973715) | soporte con bridas | existe como solucion fuera de lo 100 % impreso |

## 2. Propuestas nuevas **[propuesta]**

Se suman a las A-G ya documentadas:

- **H. Banda con cremallera (tipo precinto impreso)**: una banda flexible de PETG rodea el palo y su
  cabeza lleva un trinquete (`pawl`); es la version impresa del zip-tie. Ajusta a 22 o 24 mm sin cambiar
  la pieza. Debil ante deslizamiento axial; sirve para ganchos y bandejas livianas. Se reajusta si la
  cabeza tiene una palanca. Referencia: abrazaderas con ratchet (fila anterior).
- **I. Cuña de traba de dos piezas**: collar con una ranura inclinada y una cuña que se inserta de costado
  y se traba con un diente (sin rosca ni tornillo). La cuña aprieta radialmente (cono de 5-8 grados) y el
  collar flexa.
- **J. Rosca de paso grueso para collet**: collar partido + anillo roscado con paso 4-6 mm y filetes
  trapezoidales. Probar con la rosca de los collares de pesas como punto de partida; imprimir el anillo con
  el eje vertical.
- **K. Cierre por tension entre dos topes**: como el tension jack, un par de collares con palo intermedio que se
  separa girando una rosca; sostiene la estructura apretada contra piso y techo o entre dos tablas. Util para
  las 4 esquinas de un estante modular.
- **L. Giro de un cuarto de vuelta (bayoneta) en la pieza**: el palo no se toca; la pieza es la que tiene dos
  mitades que giran 90 grados para cerrar y llevan dientes de traba a ambos lados. Una mitad se desliza
  por el palo y la otra tapa.
- **M. Estriado de la madera**: con una lima o un taladro hacer 2-3 muescas poco profundas en el palo; el
  resalte del brazo flexible cae ahi (como G pero sin pasador). Fiable, pero modifica el palo.
- **N. Combinacion**: el nervio de agarre (C) + un tope fisico (`manguito_tope`) sostiene mas que cada uno por separado.

## 3. Datos para elegir material (resumidos de las fuentes)
- Cualquier cuña o rosca que haga fuerza: **PETG o nailon, nunca PLA**; imprimir con las capas a lo largo del esfuerzo.
- Las roscas impresas se aprietan mejor con juego de unos 0.5 mm entre rosca y contrarrosca.
- El palo absorbe barniz/humedad y cambia de diametro: medir **despues** de tratar el palo.
- Vender o redistribuir diseños ajenos requiere revisar la licencia (el de Fox & Giraffe es no comercial).

## 4. Que implementar primero (recomendacion)
1. **H (banda con cremallera)**: no aparecio nadie que lo haga para 22-24 mm; es el unico candidato que no necesita rosca ni tornillo y se ajusta a la ovalidad del palo.
2. **J (collet + anillo roscado)**: la unica opcion que da una traba "fuerte" sin tornillo; riesgo: el anillo.
3. **K (tension)** si se quiere aprovechar un piso y un techo o dos topes.
Antes de cualquiera: seguir el protocolo de pruebas de `alternativas_sin_tornillo.md` §6 (calibre y `prueba_agarre`).

## Fuentes (resumenes de busqueda; paginas no abiertas)
- Parametric dowel and tube joiners: https://makerworld.com/models/2933746
- Silla press-fit: https://makerworld.com/models/1281823
- Broomstick connection for clothes (Printables): https://www.printables.com/model/1479620-broomstick-connection-for-clothes
- Customizable 3D Printed Furniture (Instructables): https://instructables.com/Customizable-3D-Printed-Furniture
- Chois: https://www.trendhunter.com/trends/3d-printed-dowel-furniture-joints
- Cuña y pasador cola de milano: https://makerworld.com/models/2073394
- Abrazadera angular con cuña impresa: https://makerworld.com/models/1684750
- Collar de pesas roscado: https://makerworld.com/it/models/2870508-quick-lock-threaded-dumbbell-collars-5-sizes
- Cuñas Maslow (nylon): https://forums.maslowcnc.com/t/nylon-clamping-wedges/25737
- Fox & Giraffe dowel locked joint: https://sketchfab.com/3d-models/dowel-locked-joint-sushi-inside-out-1592093148a74a44b7757fa239e11802
- Cam lock impreso: https://www.printables.com/model/1475817-printable-ikea-style-cam-lock
- Universal rod connectors: https://www.stlfinder.com/model/universal-rod-connectors-pBXKnJms/1470570
- Rod and connections shelf support: https://stlfinder.com/model/rod-and-connections-shelf-support-5DrFqqsA/1890768
- Ratcheting clamp: https://makerworld.com/de/models/1911336-ratcheting-clamp
- Print-in-place ratchet: https://myminifactory.com/object/3d-print-ratchet-clamp-print-in-place-89776
- DTI clamps (collet + tuerca): https://www.printables.com/model/1043999-dti-clamps
- Collet parametrico: https://makerworld.com/es/models/2938039-fully-parametric-customizable-collet
