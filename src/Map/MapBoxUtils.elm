module MapBoxUtils exposing(..)

import ProjectionWebMercator
import Types exposing(tilesFromZoom)

createMapBoxUrl zoomInt xInt yInt = 
  let
    x = String.fromInt xInt
    y = String.fromInt yInt
    zoom = String.fromInt zoomInt
  in
    "http://tile.stamen.com/terrain-background/"++zoom++"/"++x++"/"++y++".png"


createWmsUrl zoomInt xInt yInt = 
  let
    
    xLeft = xInt * 256
    xRight = xLeft + 256
    yTop = yInt * 256
    yBottom = yTop + 256
    xLeftLong = (180/pi *(ProjectionWebMercator.xToLong xLeft zoomInt))
    xRightLong = (180/pi *(ProjectionWebMercator.xToLong xRight zoomInt))

    yTopLat = (180/pi *(ProjectionWebMercator.yToLat yTop zoomInt))

    yBottomLat = (180/pi *(ProjectionWebMercator.yToLat yBottom zoomInt))

    xLeftLong2 = String.fromFloat (ProjectionWebMercator.longToMeters xLeftLong)
    xRightLong2 = String.fromFloat (ProjectionWebMercator.longToMeters xRightLong)

    yTopLat2 = String.fromFloat (ProjectionWebMercator.latToMeters yTopLat)

    yBottomLat2 = String.fromFloat (ProjectionWebMercator.latToMeters yBottomLat)


    
    
    -- maxTiles = (tilesFromZoom zoomInt) - 1
    
    -- xLeftLong = String.fromFloat ((Basics.toFloat xInt / Basics.toFloat maxTiles) * 20037508.34)
    -- xRightLong = String.fromFloat ((Basics.toFloat(xInt+1) / Basics.toFloat maxTiles) * 20037508.34)

    -- yTopLat = String.fromFloat ((Basics.toFloat yInt / Basics.toFloat maxTiles) * 20037508.34)
    -- yBottomLat = String.fromFloat ((Basics.toFloat (yInt+1) / Basics.toFloat maxTiles) * 20037508.34)

    
  in
  --"http://tile.stamen.com/terrain-background/"++zoom++"/"++x++"/"++y++".png"
  -- http://localhost:1234/api/v3/wms/?SERVICE=WMS&REQUEST=GetMap&VERSION=1.1.1&LAYERS=dem%3Anl&STYLES=dem_nl&FORMAT=image%2Fpng&TRANSPARENT=false&HEIGHT=256&WIDTH=256&TIME=2020-07-19T07%3A47%3A34&SRS=EPSG%3A3857&BBOX=577252.437609651,6799838.036249279,587036.3772301537,6809621.975869781
-- https://nxt3.staging.lizard.net/api/v3/wms/?SERVICE=WMS&REQUEST=GetMap&VERSION=1.1.1&LAYERS=dem%3Anl&STYLES=dem_nl&FORMAT=image%2Fpng&TRANSPARENT=false&HEIGHT=256&WIDTH=256&TIME=2020-07-19T07%3A47%3A34&SRS=EPSG%3A3857&BBOX=577252.437609651,6799838.036249279,587036.3772301537,6809621.975869781
-- https://nxt3.staging.lizard.net/api/v3/wms/?SERVICE=WMS&REQUEST=GetMap&VERSION=1.1.1&LAYERS=dem%3Anl&STYLES=dem_nl&FORMAT=image%2Fpng&TRANSPARENT=false&HEIGHT=256&WIDTH=256&TIME=2020-07-19T07%3A47%3A34&SRS=EPSG%3A3857&BBOX=10312846.75816047,6587673.97479452,10352059.103248531,6626886.319882583
-- http://localhost:1234/api/v3/wms/?SERVICE=WMS&REQUEST=GetMap&VERSION=1.1.1&LAYERS=dem%3Anl&STYLES=dem_nl&FORMAT=image%2Fpng&TRANSPARENT=false&HEIGHT=256&WIDTH=256&TIME=2020-07-19T07%3A47%3A34&SRS=EPSG%3A3857&BBOX=4.921874999999983,52.482780222078205,5.625000000000006,52.05249047600099
    -- "/api/v3/wms/?SERVICE=WMS&REQUEST=GetMap&VERSION=1.1.1&LAYERS=dem%3Anl&STYLES=dem_nl&FORMAT=image%2Fpng&TRANSPARENT=false&HEIGHT=256&WIDTH=256&TIME=2020-07-19T07%3A47%3A34&SRS=EPSG%3A3857&BBOX="++(String.fromInt xLeft)++","++(String.fromInt yTop)++","++(String.fromInt xRight)++","++(String.fromInt yBottom)
    --  "/api/v3/wms/?SERVICE=WMS&REQUEST=GetMap&VERSION=1.1.1&LAYERS=dem%3Anl&STYLES=dem_nl&FORMAT=image%2Fpng&TRANSPARENT=false&HEIGHT=256&WIDTH=256&TIME=2020-07-19T07%3A47%3A34&SRS=EPSG%3A3857&BBOX="++xLeftLong2++","++yTopLat2++","++xRightLong2++","++yBottomLat2
    --  /api/v3/wms/?SERVICE=WMS&REQUEST=GetMap&VERSION=1.1.1&LAYERS=dem%3Anl&STYLES=dem_nl&FORMAT=image%2Fpng&TRANSPARENT=false&HEIGHT=256&WIDTH=256&TIME=2020-07-19T07%3A47%3A34&SRS=EPSG%3A3857&BBOX=547900.6186718731,2974377.691507161,587036.377148437,2957381.2475556936
         "/api/v3/wms/?SERVICE=WMS&REQUEST=GetMap&VERSION=1.1.1&LAYERS=dem%3Anl&STYLES=dem_nl&FORMAT=image%2Fpng&TRANSPARENT=false&HEIGHT=256&WIDTH=256&TIME=2020-07-19T07%3A47%3A34&SRS=EPSG%3A3857&BBOX="++xLeftLong2++","++yBottomLat2++","++xRightLong2++","++yTopLat2

        --  http://localhost:1234/api/v3/wms/?SERVICE=WMS&REQUEST=GetMap&VERSION=1.1.1&LAYERS=dem%3Anl&STYLES=dem_nl&FORMAT=image%2Fpng&TRANSPARENT=false&HEIGHT=256&WIDTH=256&TIME=2020-07-19T07%3A47%3A34&SRS=EPSG%3A3857&BBOX=391357.5847656237,2991374.1354586314,469629.10171874845,3025367.023361571
-- 545454.6337670891,2982875.913482898,547900.6186718731,2983938.1912298645