# Docker ShogiGUI + Yaneuraou / orqha

## Docker
### Configuration
Choose the correct `YANEURAOU_TARGET_CPU`, as of may 2020 you can choose from :
- INTEL : AVX512, AVX2, SSE42, SSE41, SSE2, NO_SSE
- ARM : OTHER
- AMD : ZEN2

AVX2 should suit most, to check what is available to your CPU :
```bash
lscpu | grep -Eo '(avx|sse)[^ ]+'
```

### Building the image
```bash
SHOGIGUI_VERSION=0.0.7.21
YANEURAOU_VERSION=4.91
YANEURAOU_TARGET_CPU=AVX2
docker build --build-arg NPROC=$(nproc) \
             --build-arg SHOGIGUI_VERSION=$SHOGIGUI_VERSION \
             --build-arg YANEURAOU_VERSION=$YANEURAOU_VERSION \
             --build-arg YANEURAOU_TARGET_CPU=$YANEURAOU_TARGET_CPU \
             -t shogigui${SHOGIGUI_VERSION}:yaneuraou${YANEURAOU_VERSION}-${YANEURAOU_TARGET_CPU} \
             -t shogigui:latest .
```

### Optional : Remove the builder image
```bash
docker image prune --filter label=app=shogigui --filter label=stage=build
```

## Running ShogiGUI
### First run
Retrieve `settings.xml` with pre-configured parameters (engine configured, English language, sound disabled...)
```bash
mkdir $HOME/.shogigui/
wget -O $HOME/.shogigui/settings.xml https://raw.githubusercontent.com/jruffet/docker-shogigui/master/settings.xml
```

### Launch the interface
```bash
docker run --rm --name shogigui --net host --user $UID:$UID -e DISPLAY -v $HOME/.shogigui/settings.xml:/shogi/shogigui/settings.xml  shogigui:latest
```

If you want to load / save game files, you can add `-v $HOME/somedir:/shogi/games`

To use the simplified pieces embedded in this repository, you can go to Tools>Options>Design and check Image/Piece.

## Troubleshooting
### Could not open display (X-Server required. Check your DISPLAY environment variable)
This should not happen if you use `--user $UID:$UID` when running the container.

To circumvent the issue you can run : 
```bash
xhost +local:
```

## Known bugs
- If sound is activated in ShogiGUI, every piece move will cap a core to 100% usage
- When engine analysis is running and you move your mouse in the engine output box, ShogiGUI will eventually crash with `System.ArgumentOutOfRangeException: Specified argument was out of the range of valid values.`
