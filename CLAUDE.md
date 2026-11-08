# Baquetas: notas para Claude

## Reglas de trabajo
- **No compilar ni exportar STL por sesion a menos que se pida.** No correr `./build.sh`
  completo, ni `docker build/run`, ni exportar todas las piezas "para verificar". Una
  comprobacion puntual de una sola pieza que se esta editando (un `openscad -D pieza=...`)
  es aceptable solo si hace falta para no entregar un error de sintaxis; el resto de
  la compilacion la hace el usuario o GitHub Actions (`.github/workflows/build.yml`).
- Nada de lo nuevo esta probado impreso: no afirmar que "funciona", solo que compila.
- No hacer commit sin que se pida.
- Idioma de los comentarios y docs: espanol.

## Donde esta cada cosa
- `readme.md`: estructura y uso. `investigaciones/`: propuestas y pendientes.
- `investigaciones/pendientes.md`: lista de lo que falta hacer (leerla al empezar).
- `config.scad`: perfiles de impresion (`pico04`, `pico08`) y medidas del palo.
- `piezas.scad` + `build.sh`: un STL por pieza. Una pieza nueva = una linea en cada uno.
