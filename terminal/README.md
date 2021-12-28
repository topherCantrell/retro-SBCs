# Serial Tile Engine

The tile engine renders a map of 32x18 tiles on the PI monitor. Each tile is 32x32 pixels.

The tile engine maintains an internal world buffer of 64x36 tiles. The controller sets the X,Y
of the viewport.

The tile engine has a list of 256 tiles. The controller uploads the pixel data for the
tiles.

![](tiles.jpg)

## Serial Commands

`mode(m)` 128,m: Set the display operating mode. 0=plain text background (no tile engine), 1=tile engine

`setTile(n,data)` 129,n,128_bytes: Set the pixel data for the given tile

`setMap(x,y,value)` 130,x,y,v: Set the display map to the given value

`setView(x,y)` 131,x,y: Set the viewport coordinates

`fill(x1,y1,width,height,value)` 132,x1,y1,w,h,v: Fill a rectangle of the world map

`update()` 133: Update the display (changes are kept internally until this is called)
