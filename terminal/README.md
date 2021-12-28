# Serial Tile Engine

The tile engine renders a map of 32x18 tiles on the PI monitor. Each tile is 32x32 pixels.

The tile engine maintains an internal world buffer of 64x36 tiles. The controller sets the X,Y
of the viewport.

The tile engine has a list of 256 tiles. The controller uploads the pixel data for the
tiles.

![](tiles.jpg)

## Serial Commands

`mode(m)` Set the display operating mode. 0=plain text background (no tile engine), 1=tile engine

`setTile(n,data)` Set the pixel data for the given tile

`setMap(x,y,value)` Set the display map to the given value

`setView(x,y)` Set the viewport coordinates

`fill(x1,y1,width,height,value)` Fill a rectangle of the world map

`update()` Update the display (changes are kept internally until this is called)
