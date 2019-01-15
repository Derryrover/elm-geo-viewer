module SizeXYLongLat exposing (..)

import ProjectionWebMercator

type alias MapDimensions = 
  { width: Float
  , height: Float
  , longLeft: Float
  , longRight: Float
  , latTop: Float
  , latBottom: Float
  }

getAdaptedMapWidthHeight mapDimensions = 
  let
    xLeft = ProjectionWebMercator.longToX mapDimensions.longLeft 0
    xRight = ProjectionWebMercator.longToX mapDimensions.longRight 0
    deltaX = abs (xRight - xLeft)
    yTop = ProjectionWebMercator.latToY mapDimensions.latTop 0
    yBottom = ProjectionWebMercator.latToY mapDimensions.latBottom 0
    deltaY = abs (yTop - yBottom)
    relativeWidthHeight = mapDimensions.height / mapDimensions.width
    relativeLongLat =  deltaY / deltaX
    newWH =
      if (relativeLongLat < relativeWidthHeight) then -- coordinates are wider
        {
          width = mapDimensions.height / relativeLongLat
        , height = mapDimensions.height
        }
      else 
        {
          width = mapDimensions.width 
        , height = mapDimensions.width * relativeLongLat
        }
  in
    newWH

getZoomLevel mapDimensions testZoom = 1