# Docker ShogiGUI + Yaneuraou
This repository aims at easily bringing ShogiGUI + YaneuraOu to Linux.

It is centered around a helper script (named `docker-shogigui`) to do all the dirty work for you (building / running the docker image, with install / setup of shogiGUI, compilation of YaneuraOu, configuration with NNUE eval functions, and much more...)

The default configuration file provided sets the following options :

- English language
- Set up japanese fonts to look better
- Multiple up-to-date engines configured (YaneuraOu/elmo and YaneuraOu/orqha-1018)
- Disable sound (see "Troubleshooting" below)
- Allow the usage of simplified pieces (see "Simplified pieces" below)

## Pre-requesites
You need to install docker so that it is controllable by your desktop user.

Doing so is outside the scope of this repository, though.

## Building the image
```bash
./docker-shogigui --build
```
This will also automatically select the best CPU flag to use to compile YaneuraOu.

### Optional : Remove the builder image
```bash
./docker-shogigui --cleanup
```
Note that doing so will save space, but building the image again will take longer.


## Running ShogiGUI inside a container
```bash
./docker-shogigui --run
```
That simple.

### Load/Save games
If you want to load / save game files, you can type :
```bash
./docker-shogigui --run -g $HOME/somedir
```
This directory will be accessible at `/shogi/games` inside the container

### Update settings.xml
Along the way, on this repository engines may be added / replaced / enhanced.

To keep up with those, you have to manually run (**after** having built the latest image) :
```bash
./docker-shogigui --update-settings
```
This is non-destructive, as it will only add missing engines to the settings.xml file.


### And more...
For all the available commands, type :
```bash
./docker-shogigui --help
```

### Simplified pieces
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
