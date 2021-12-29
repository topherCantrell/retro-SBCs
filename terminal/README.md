# Serial Tile Engine

The tile engine renders a rectangular map of tiles on the PI monitor. Each tile is 32x32 pixels. The
controller configures the width, height, screen-x, and screen-y of the rendered map. Any non-rendered
tile is filled with tile 0.

The tile engine maintains an internal world buffer of 64x36 tiles. The controller sets the X,Y
of the viewport.

The tile engine has a list of 256 tiles. The controller uploads the pixel data for the
tiles.

![](tiles.jpg)

## Serial Commands

`mode(m)` 128,m: Set the display operating mode. 0=plain text background (no tile engine), 1=tile engine

`setTile(n,data)` 129,n,128_bytes: Set the pixel data for the given tile

`setMap(worldx,worldy,value)` 130,x,y,v: Set the display map to the given value

`configureView(screenx,screeny,width,height)` 131: screenx,screeny,width,height

`setView(worldx,worldy)` 132,x,y: Set the viewport coordinates

`fill(worldx1,worldy1,width,height,value)` 133,x1,y1,w,h,v: Fill a rectangle of the world map

`update()` 134: Update the display (changes are kept internally until this is called)
