# Imagen para generar los STL sin instalar nada:
#   docker build -t baquetas .
#   docker run --rm -v "$PWD/stl:/app/stl" baquetas            # perfil pico04
#   docker run --rm -v "$PWD/stl:/app/stl" baquetas ./build.sh pico08
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install -y --no-install-recommends openscad xvfb xauth \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY . .
# xvfb-run da un display virtual por si OpenSCAD lo pide al exportar
ENTRYPOINT ["xvfb-run", "-a"]
CMD ["./build.sh"]
