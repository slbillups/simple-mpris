<div align="center">
  <img src="image/preview.jpg" width="250" />
  <h1>Simple MPRIS</h1>
</div>

A minimalist MPRIS media player widget for KDE Plasma 6. I made this because I'm a habitual ricer.

I built this without any idea that [plasmusic-toolbar](https://github.com/ccatterina/plasmusic-toolbar) already existed, so if you don't like my applet, check out ccaterina's!

### Install

either download this repo as a zip or clone this repo and then either:
rename the .zip .plasmoid and run:

```sh
kpackagetool6 -i simple-mpris.plasmoid --type Plasma/Applet
```

or if you cloned the repo


```sh
 mv simple-mpris $HOME/.local/share/plasma/plasmoids
```

then either log out/log back in or ``kquitapp6 plasmashell && kstart plasmashell``

### keybinds



 **left/right arrow keys** to seek -/+ 5 seconds
  
  **ctrl+left/right arrow keys** to go to previous/next song

  **up/down arrow keys** to increase/decrease volume by 5%

  **spacebar while in focus** to pause/play current song

### Other Features
- text overlay to display current position when updating seek/volume

- Adjustable widget opacity (use mouse scroll up/down while it has focus)

- change the location of the volume %/seek text via the applet's plasma 

- more configuration options in the applet configuration page (Alt+D or right click -> configure simple-mpris)

### miscellanious info

Resizing the container may look/feel janky, this is actually intended because of how applets are resized in kirigami units, it allows the image to be freely resized while keeping the aspect ratio of the cover art to prevent clipping the exterior container.

 However if for whatever reason you want to change it, just change lines 109-110 in contents/ui/main.qml. YTMND.


