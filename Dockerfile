# Shogigui + Yaneuraou (elmo, orqha1018)
ARG SHOGIGUI_VERSION=0.0.7.23
ARG YANEURAOU_VERSION=6.00
ARG YANEURAOU_TARGET_CPU=AVX2
ARG NPROC=4

# Elmo WCSC30
ARG ELMO_GDRIVE_ID="1qhutTzaog4pHqh0OPAhJuf8mCwPAl5r7"

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
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Google drive downloader
RUN pip3 install gdown

RUN curl -LO https://www.qhapaq.org/static/media/bin/orqha1018.7z && \
    7z x orqha1018.7z

ARG ELMO_GDRIVE_ID
RUN gdown --id $ELMO_GDRIVE_ID -O elmo.zip && \
    unzip elmo.zip && \
    rm -f elmo.zip && \
    mv elmo* elmo

ARG YANEURAOU_VERSION
ARG YANEURAOU_TARGET_CPU
ARG NPROC
RUN curl -LO https://github.com/yaneurao/YaneuraOu/archive/v${YANEURAOU_VERSION}.tar.gz && \
    tar xzfv v${YANEURAOU_VERSION}.tar.gz && \
    cd YaneuraOu-${YANEURAOU_VERSION}/source && \
    make -j${NPROC} TARGET_CPU=${YANEURAOU_TARGET_CPU}

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
COPY --from=build /build/orqha-1018 /shogi/engines/yaneuraou/orqha-1018
COPY --from=build /build/elmo/eval /shogi/engines/yaneuraou/elmo

ARG YANEURAOU_VERSION
COPY --from=build /build/YaneuraOu-${YANEURAOU_VERSION}/source/YaneuraOu-by-gcc /shogi/engines/yaneuraou/yaneuraou

ARG SHOGIGUI_VERSION
COPY --from=build /build/ShogiGUIv${SHOGIGUI_VERSION} /shogi/shogigui
COPY settings.xml /shogi/shogigui/settings.xml
RUN chmod 0666 /shogi/shogigui/settings.xml

ENV HOME=/tmp

CMD ["/usr/bin/mono", "/shogi/shogigui/ShogiGUI.exe"]
