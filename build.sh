#!/usr/bin/env bash
# Exporta un STL por pieza fisica, ordenado por tipo.
#
#   ./build.sh                 # perfil pico04 -> stl/pico04/
#   ./build.sh pico08          # perfil pico08 -> stl/pico08/
# Los perfiles estan definidos en config.scad (_perfiles).
#   ./build.sh pico04 hirth_A  # una sola pieza
#   OUT=/otra/carpeta ./build.sh
#
# Para agregar una pieza: lineas en piezas.scad y en LISTA (tipo/nombre:pieza).
set -euo pipefail
cd "$(dirname "$0")"

OPENSCAD="${OPENSCAD:-$(command -v openscad || echo /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD)}"
PERFIL="${1:-pico04}"
SOLO="${2:-}"
OUT="${OUT:-stl}/$PERFIL"

ARGS=(-D "_perfil=\"$PERFIL\"")   # config.scad valida que el perfil exista

LISTA=(
  juntas/doble:junta_doble
  juntas/doble_linea:junta_doble_linea
  juntas/array_gradual:junta_array_gradual
  juntas/array_extremos:junta_array_extremos
  juntas/array_degrade:junta_array_degrade
  juntas/array_solo_extremos:junta_array_solo_extremos
  juntas/T:junta_T
  juntas/angulo:junta_angulo
  juntas/union_lineal:union_lineal
  juntas/terminal:terminal
  hirth/A:hirth_A
  hirth/B:hirth_B
  hirth/plana_A:hirth_plana_A
  hirth/plana_B:hirth_plana_B
  patas/base:pata_base
  patas/rotula_vastago:rotula_vastago
  patas/rotula_copa:rotula_copa
  apoyos/pared_perpendicular:pared_perpendicular
  apoyos/pared_paralelo:pared_paralelo
  apoyos/estante_un_brazo:estante_un_brazo
  apoyos/estante_esquinero:estante_esquinero
  diagonales/diagonal_45:diagonal_45
  diagonales/diagonal_45_doble:diagonal_45_doble
  diagonales/diagonal_135:diagonal_135
  diagonales/brazo:brazo
  diagonales/brazo_esquinero:brazo_esquinero
  tripodes/hub_3_patas:tripode_3
  tripodes/hub_4_patas:tripode_4
  tripodes/punta_pata_25:punta_pata_25
  tripodes/punta_pata_20:punta_pata_20
  sin_tornillo/calibre_palo:flexible_calibre
  sin_tornillo/prueba_agarre:flexible_prueba
  sin_tornillo/acople:flexible_acople
  sin_tornillo/collar_deslizante:flexible_collar
  sin_tornillo/tapon:flexible_tapon
  sin_tornillo/cuna_ajuste:flexible_cuna
  elementos/manguito_tope:elem_manguito_tope
  elementos/hub_cruce:elem_hub_cruce
  elementos/bandeja:elem_bandeja
  elementos/canasto:elem_canasto
  elementos/brazo_estante:elem_brazo_estante
  elementos/multi_gancho:elem_multi_gancho
  elementos/base:elem_base
  elementos/tapa_plato:elem_tapa_plato
)

fallos=0
for item in "${LISTA[@]}"; do
  destino="${item%%:*}"; pieza="${item##*:}"
  [[ -n "$SOLO" && "$SOLO" != "$pieza" ]] && continue
  mkdir -p "$OUT/$(dirname "$destino")"
  if "$OPENSCAD" "${ARGS[@]}" -D "pieza=\"$pieza\"" -o "$OUT/$destino.stl" piezas.scad >/dev/null 2>"$OUT/$destino.log"; then
    rm -f "$OUT/$destino.log"; echo "ok     $OUT/$destino.stl"
  else
    echo "FALLO  $pieza (ver $OUT/$destino.log)"; fallos=$((fallos+1))
  fi
done
exit $((fallos > 0))
