# Shogigui + Yaneuraou (elmo, suisho, orqha1018)
ARG SHOGIGUI_VERSION=0.0.7.30
ARG YANEURAOU_VERSION=7.61
ARG YANEURAOU_TARGET_CPU=AVX2
ARG NPROC=4

# Elmo WCSC30
ARG ELMO_GDRIVE_ID="1qhutTzaog4pHqh0OPAhJuf8mCwPAl5r7"
# Suisho 5
ARG SUISHO_NNUE="https://github.com/HiraokaTakuya/get_suisho5_nn/raw/f182be18a81e0277afa8a0c234e88b28fc584a1a/suisho5_nn/nn.bin"
# orqha1018
ARG ORQHA_7Z="https://www.qhapaq.org/static/media/bin/orqha1018.7z"

# Build stage
FROM ubuntu:22.04 AS build
LABEL app=shogigui
LABEL stage=build

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    clang \
    make \
    curl \
    unzip \
    p7zip-full \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Google drive downloader
RUN pip3 install gdown

ARG ORQHA_7Z
RUN curl -LO $ORQHA_7Z && \
    7z x orqha1018.7z

ARG ELMO_GDRIVE_ID
RUN gdown --id $ELMO_GDRIVE_ID -O elmo.zip && \
    unzip elmo.zip && \
    rm -f elmo.zip && \
    mv elmo* elmo

ARG SUISHO_NNUE
RUN mkdir suisho
RUN curl -L $SUISHO_NNUE -o suisho/nn.bin

ARG YANEURAOU_VERSION
ARG YANEURAOU_TARGET_CPU
ARG NPROC
RUN curl -LO https://github.com/yaneurao/YaneuraOu/archive/V${YANEURAOU_VERSION}.tar.gz && \
    tar xzfv V${YANEURAOU_VERSION}.tar.gz && \
    cd YaneuraOu-${YANEURAOU_VERSION}/source && \
    make -j${NPROC} TARGET_CPU=${YANEURAOU_TARGET_CPU}

ARG SHOGIGUI_VERSION
RUN curl -LO http://shogigui.siganus.com/shogigui/ShogiGUIv${SHOGIGUI_VERSION}.zip && \
    unzip ShogiGUIv${SHOGIGUI_VERSION}.zip


# Actual image, based on the work of https://github.com/s-shin/docker-shogi-gui
FROM ubuntu:22.04

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

COPY simple_pieces.png /shogi/pieces/simple_pieces.png
COPY --from=build /build/orqha-1018 /shogi/engines/yaneuraou/orqha-1018
COPY --from=build /build/elmo/eval /shogi/engines/yaneuraou/elmo
COPY --from=build /build/suisho /shogi/engines/yaneuraou/suisho

ARG YANEURAOU_VERSION
COPY --from=build /build/YaneuraOu-${YANEURAOU_VERSION}/source/YaneuraOu-by-gcc /shogi/engines/yaneuraou/yaneuraou

COPY --from=build /build/ShogiGUI /shogi/shogigui
COPY settings.xml /shogi/shogigui/settings.xml
RUN chmod 0666 /shogi/shogigui/settings.xml

ENV HOME=/tmp

CMD ["/usr/bin/mono", "/shogi/shogigui/ShogiGUI.exe"]
