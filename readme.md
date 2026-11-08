# Baquetas
## Sistema modula de acoples (impresos 3D) para varillas de madera


## consejos dei mpresion
para pico 0.4 o menos holguras de 0.5 mm estan bien
para picos de 0.8 esrecomendabl e subir la holgura

## estructura y uso
+ `config.scad`: valores comunes y perfiles de impresion (`pico04`, `pico08`)
+ `juntas.scad`, `hirth.scad`, `hirth_plano.scad`, `patas.scad`, `apoyos.scad`: piezas (cada una trae una demo al abrirla)
+ `hueco_baqueta.scad` y `utils/`: huecos, tuercas y avellanados
+ `piezas.scad` + `build.sh`: exportan un STL por pieza en `stl/<perfil>/<tipo>/`

        ./build.sh              # todas, perfil pico04
        ./build.sh pico08       # todas, perfil pico08
        ./build.sh pico08 hirth_A   # una sola pieza

+ `bambu/`: proyecto y STL de Bambu Studio
+ `investigaciones/`: ideas y codigo apartado para retomar
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
