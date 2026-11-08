#!/usr/bin/env bash
# Calculadora de diagonales, cruces y tripodes (ver calculadora.scad).
#   ./calcular.sh diagonal dx=600 dz=400
#   ./calcular.sh diagonal angulo=40 dx=600
#   ./calcular.sh cruz dx=800 dz=600
#   ./calcular.sh tripode altura=700 apertura=20 patas=3
#   ./calcular.sh diagonal dx=600 dz=400 _perfil=pico08     # otro perfil
set -euo pipefail
cd "$(dirname "$0")"
OPENSCAD="${OPENSCAD:-$(command -v openscad || echo /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD)}"
[[ $# -ge 1 ]] || { sed -n '2,7p' "$0"; exit 1; }
modo="$1"; shift
args=(-D "modo=\"$modo\"")
for kv in "$@"; do
  k="${kv%%=*}"; v="${kv#*=}"
  if [[ "$k" == "_perfil" ]]; then args+=(-D "_perfil=\"$v\""); else args+=(-D "$k=$v"); fi
done
tmp="$(mktemp -t calcular).echo"
trap 'rm -f "$tmp"' EXIT
"$OPENSCAD" "${args[@]}" -o "$tmp" calculadora.scad >/dev/null 2>"$tmp.err" || { cat "$tmp.err" >&2; rm -f "$tmp.err"; exit 1; }
salida="$(sed -e 's/^ECHO: "//' -e 's/"$//' "$tmp")"
rm -f "$tmp.err"
if grep -q '^ERROR' <<<"$salida"; then grep '^ERROR' <<<"$salida" >&2; exit 1; fi
echo "$salida"
