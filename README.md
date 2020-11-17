# Docker ShogiGUI + Yaneuraou

## Pre-requesites
You need to install docker so that it is controllable by your desktop user.

Doing so is outside the scope of this repository, though.

## Building the image
```bash
./shogigui --build
```
This will also automatically select the best CPU flag to use to compile YaneuraOu.

### Optional : Remove the builder image
```bash
./shogigui --cleanup
```
Note that doing so will save space, but building the image again will take longer.


## Running ShogiGUI
```
./shogigui
```
That simple.

### Load/Save games
If you want to load / save game files, you can type :
```bash
./shogigui -g $HOME/somedir
```
This directory will be accessible at `/shogi/games` inside the container

### Update settings.xml
Along the way, on this repository engines may be added / replaced / enhanced.

To keep up with those, you have to manually run :
```bash
./shogigui --update-settings
```
This is non-destructive, as it will only add missing engines to the settings.xml file.


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
