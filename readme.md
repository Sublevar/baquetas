# Baquetas
## Sistema modula de acoples (impresos 3D) para varillas de madera


## consejos dei mpresion
para pico 0.4 o menos holguras de 0.5 mm estan bien
para picos de 0.8 esrecomendabl e subir la holgura

## estructura y uso
+ `config.scad`: valores comunes y perfiles de impresion (`pico04`, `pico08`)
+ `juntas.scad`, `hirth.scad` (un solo script, `junta_hirth(modo = "tope" | "cilindros" | "cilindros_90")`: tope con pared; cilindros macizos con hull + cilindro que niega los dientes + union de dientes, palos libres solo entre 150 y 210 grados; `cilindros_90` libres desde 90 grados; tornillo central pasante), `patas.scad`, `apoyos.scad`: piezas (cada una trae una demo al abrirla)
+ `hueco_baqueta.scad` y `utils/`: huecos, tuercas y avellanados
+ `diagonales.scad`: acoples con diagonal a cualquier angulo y brazos (angulo 90)
+ `tripodes.scad`: hub de patas (`pie_tripode`) y zapata (`punta_pata`)
+ `calculadora.scad` + `calcular.sh`: largos de varilla y angulos (hipotenusa = adyacente / cos)
+ `utils/trigonometria.scad`: funciones de la calculadora y de las distancias minimas
+ `sin_tornillo.scad` + `utils/flexion.scad`: acoples de brazos flexibles para palos de 22 a 24 mm no simetricos (ver `investigaciones/alternativas_sin_tornillo.md`, seccion 6)
+ `elementos_flex.scad`: manguito, hub de cruce, bandeja, canasto, brazo de estante, multi-gancho, base y tapa con plato; los parametros del palo estan en `config.scad` (`_palo_*`) y los puntos a probar marcados `PRUEBAS:`
+ `muebles.scad`: con tornillo de presion, para armar estantes, cajones y paneles entre 4 palos: `esquinero_tabla`, `guia_cajon`, `bolsillo_panel` (esquinero triangular de 3 agujeros, sin cantos; propuesta y pendientes en `investigaciones/propuesta_muebles.md`; sin probar impresas)
+ `piezas.scad` + `build.sh`: exportan un STL por pieza en `stl/<perfil>/<tipo>/`
+ `investigaciones/pendientes.md`: advertencias y lo que falta hacer (leer antes de imprimir)
+ `Dockerfile` y `.github/workflows/build.yml`: lo mismo sin instalar nada (Docker) o en la nube (GitHub Actions: un job por perfil, los STL quedan como artefactos de cada ejecucion)

        ./build.sh              # todas, perfil pico04
        ./build.sh pico08       # todas, perfil pico08
        ./build.sh pico08 hirth_A   # una sola pieza

### calculadora
        ./calcular.sh diagonal dx=600 dz=400            # puntal entre poste y travesano
        ./calcular.sh diagonal angulo=40 dx=600
        ./calcular.sh cruz dx=800 dz=600                # diagonales de un marco
        ./calcular.sh tripode altura=700 apertura=20 patas=3
        ./calcular.sh diagonal dx=600 dz=400 _perfil=pico08
        ./calcular.sh flexible d_min=22 d_max=24 ovalidad=0.5 precarga=0.3   # acople sin tornillo

+ `bambu/`: proyecto y STL de Bambu Studio
+ `investigaciones/`: ideas y codigo apartado para retomar; `alternativas_sin_tornillo.md` documenta los mecanismos deslizables; `sistemas_sin_tornillo_2.md` es la segunda ronda de investigacion; `propuesta_muebles.md` la de muebles
## premisas
+ los acoples son imprimibles y modulares.

    + juntas fijas
    + juntas hirth
    + topes
    + armaduras-anillos pasantes u otras piezas
    + moviles
+ se tendran en cuenta 2 perfiles
    
    + Circulares
    + Rectangulares 
+ las fijaciones entre partes se conciben para usar un tornillo fijado a la madera o un sistema de tornillo prensando la madera 

openScad dev refes: 
https://makerworld.com/es/models/825780-round-rod-connections#profileId-978553

https://cults3d.com/es/modelo-3d/herramientas/hirth-joint-for-20x20-extrusions?__cf_chl_f_tk=msKc5sPsWW3fqOsVxsy736P1camn4km5BtMFdVSwxXQ-1783204669-1.0.1.1-_QzsqwWdSxtgmj2dVkRNoU_TCHy9uAzFhrWwxQBOtOg 

https://github.com/AkBKukU/scad-HirthJoint

https://www.thingiverse.com/thing:6200292

https://cults3d.com/en/3d-model/tool/hirth-joint-with-openscad
