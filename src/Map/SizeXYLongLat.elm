module SizeXYLongLat exposing (..)

import ProjectionWebMercator
import List

type alias MapDimensions = 
  { width: Float
  , height: Float
  , longLeft: Float
  , longRight: Float
  , latTop: Float
  , latBottom: Float
  }

getAdaptedMapDimensions mapDimensions = 
  let
    xLeft = ProjectionWebMercator.longToX mapDimensions.longLeft 0
    xRight = ProjectionWebMercator.longToX mapDimensions.longRight 0
    xleftlog = Debug.log "xLeft" xLeft
    xrightlog = Debug.log "xRight" xRight
    deltaX = abs (xRight - xLeft)
    deltaXlog = Debug.log "deltaX" deltaX
    yTop = ProjectionWebMercator.latToY mapDimensions.latTop 0
    yBottom = ProjectionWebMercator.latToY mapDimensions.latBottom 0
    deltaY = abs (yTop - yBottom)
    deltaYlog = Debug.log "deltaY" deltaY
    relativeWidthHeight = mapDimensions.height / mapDimensions.width
    relativeLongLat =  deltaY / deltaX
    newMapDimension =
      if (relativeLongLat < relativeWidthHeight) then -- coordinates are wider
        let
          -- width = mapDimensions.height / relativeLongLat
          width = deltaY / relativeWidthHeight
          logWidth = Debug.log "width" width
          halfWidthDelta = (width - deltaX) / 2
          xLeftNew = xLeft - halfWidthDelta
          logxLeftNew = Debug.log "xLeftNew" xLeftNew
          xRightNew = xRight + halfWidthDelta
        in
        { mapDimensions |
            longLeft = ProjectionWebMercator.xToLong xLeftNew 0,
            longRight = ProjectionWebMercator.xToLong xRightNew 0
        }
      else 
        let
          height = mapDimensions.width * relativeLongLat
          halfheightDelta = (mapDimensions.height - height) / 2
          yTopNew = yTop - halfheightDelta
          yBottomNew = yBottom + halfheightDelta
        in
        { mapDimensions |
            latTop = ProjectionWebMercator.yToLat yTopNew 0,
            latBottom = ProjectionWebMercator.yToLat yBottomNew 0
        }
  in
    newMapDimension

maxZoomLevel = 16

getZoomLevel mapDimensions testZoom = 
  let
    xLeft = ProjectionWebMercator.longToX mapDimensions.longLeft testZoom
    xRight = ProjectionWebMercator.longToX mapDimensions.longRight testZoom
    deltaX = abs (xRight - xLeft)
    yTop = ProjectionWebMercator.latToY mapDimensions.latTop testZoom
    yBottom = ProjectionWebMercator.latToY mapDimensions.latBottom testZoom
    deltaY = abs (yTop - yBottom)
  in
    if (deltaX > mapDimensions.width && deltaY > mapDimensions.height) then -- current scale is too big to fit in window
      if testZoom == 0 then
        0 -- map to small for showing all even at smallest zoom !
      else
        testZoom - 1
    else if testZoom == maxZoomLevel then
      maxZoomLevel -- map bigger then maximum resolution zoomlevel
    else
      getZoomLevel mapDimensions (testZoom+1)

getTileRange mapDimensions = 
  let
    log9 = Debug.log "initialMapDimensions" mapDimensions
    adaptedMapDimensions = getAdaptedMapDimensions mapDimensions
    log10 = Debug.log "adaptedMapDimensions" adaptedMapDimensions
    zoomLevel = getZoomLevel adaptedMapDimensions 0
    xLeft = ProjectionWebMercator.longToX adaptedMapDimensions.longLeft zoomLevel
    xRight = ProjectionWebMercator.longToX adaptedMapDimensions.longRight zoomLevel
    yTop = ProjectionWebMercator.latToY adaptedMapDimensions.latTop zoomLevel
    yBottom = ProjectionWebMercator.latToY adaptedMapDimensions.latBottom zoomLevel
    xTileLeft = Basics.floor ( xLeft / 256 )
    xTileRight = Basics.ceiling ( xRight / 256 )
    yTileTop = Basics.floor ( yTop / 256 )
    yTileBottom = Basics.ceiling ( yBottom / 256 )
    -- log1 = Debug.log "xTileLeft" xTileLeft
    -- log2 = Debug.log "xTileRight" xTileRight
    -- log3 = Debug.log "xLeft" xLeft
    -- log4 = Debug.log "xRight" xRight
  in
    { x = List.range xTileLeft xTileRight
    , y = List.range yTileTop yTileBottom
    , zoomLevel = zoomLevel
    , panFromLeft = modBy (Basics.round xLeft) 256
    , panFromTop = modBy (Basics.round yTop) 256
    }
  