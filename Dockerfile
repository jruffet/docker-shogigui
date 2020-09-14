# Shogigui + Yaneuraou / orqha
ARG SHOGIGUI_VERSION=0.0.7.21
ARG YANEURAOU_VERSION=4.91
ARG YANEURAOU_TARGET_CPU=AVX2
ARG NPROC=4

# Build stage
FROM ubuntu:19.10 AS build
LABEL app=shogigui
LABEL stage=build

RUN apt-get update && \
    apt-get install -y \
    clang \
    make \
    curl \
    unzip \
    p7zip-full \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

RUN curl -LO https://www.qhapaq.org/static/media/bin/orqha.7z && \
    7z x orqha.7z

ARG YANEURAOU_VERSION
ARG YANEURAOU_TARGET_CPU
ARG NPROC
RUN curl -LO https://github.com/yaneurao/YaneuraOu/archive/V${YANEURAOU_VERSION}.tar.gz && \
    tar xzfv V${YANEURAOU_VERSION}.tar.gz && \
    cd YaneuraOu-${YANEURAOU_VERSION}/source && \
    sed "s/^TARGET_CPU =.*/TARGET_CPU = ${YANEURAOU_TARGET_CPU}/" -i Makefile && \
    make -j${NPROC}

ARG SHOGIGUI_VERSION
RUN curl -LO http://shogigui.siganus.com/shogigui/ShogiGUIv${SHOGIGUI_VERSION}.zip && \
    unzip ShogiGUIv${SHOGIGUI_VERSION}.zip


# Actual image, based on the work of https://github.com/s-shin/docker-shogi-gui
FROM ubuntu:19.10

# for tzdata
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    # mono-runtime and dependencies
    mono-runtime \
    libmono-system-windows-forms4.0-cil \
    libmono-system-management4.0-cil \
    # Resolves partial text garbling and the error on reading record file.
    libmono-i18n-cjk4.0-cil \
    libgtk2.0-0 \
    # japanese
    fonts-takao-pgothic \
    # used when downloading games from the internet (eg. shogiwars)
    ca-certificates-mono \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /etc/mono/registry
RUN chmod 0777 /etc/mono/registry

COPY simple_pieces.png /shogi/pieces/simple_pieces.png
COPY --from=build /build/orqha /shogi/engines/yaneuraou/orqha

ARG YANEURAOU_VERSION
COPY --from=build /build/YaneuraOu-${YANEURAOU_VERSION}/source/YaneuraOu-by-gcc /shogi/engines/yaneuraou/yaneuraou

ARG SHOGIGUI_VERSION
COPY --from=build /build/ShogiGUIv${SHOGIGUI_VERSION} /shogi/shogigui
COPY settings.xml /shogi/shogigui/settings.xml
RUN chmod 0666 /shogi/shogigui/settings.xml

ENV HOME=/tmp

CMD ["/usr/bin/mono", "/shogi/shogigui/ShogiGUI.exe"]
