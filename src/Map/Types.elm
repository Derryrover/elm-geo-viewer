module Types exposing (..)

import ProjectionWebMercator

type alias Window = 
  { width: Int
  , height: Int
  }

type alias GeoCoordinatePoint =
  { long: Float
  , lat: Float
  }

type alias GeoCoordinateWindow = 
  { longLeft: Float
  , longRight: Float
  , latTop: Float
  , latBottom: Float
  }

type alias PixelCoordinatePoint = 
  { x: Int
  , y: Int
  }

type alias PixelCoordinateWindow =
  { leftX: Int
  , rightX: Int
  , topY: Int
  , bottomY: Int 
  }

type alias ZoomPlusPixel = 
  { zoom: Int
  , pixelCoordinateWindow: PixelCoordinateWindow
  }

maxZoomLevel = 16
tilePixelSize = 256

getZoom: Window -> GeoCoordinateWindow -> ZoomPlusPixel
getZoom window geoCoordinateWindow = 
  getZoomRecursiveHelper maxZoomLevel window geoCoordinateWindow

getZoomRecursiveHelper: Int -> Window -> GeoCoordinateWindow -> ZoomPlusPixel
getZoomRecursiveHelper testZoom window geoCoordinateWindow = 
  let
      pixelCoordinateWindow = getPixelCoordinateWindowHelper testZoom geoCoordinateWindow
      result = 
        { zoom = testZoom
        , pixelCoordinateWindow = pixelCoordinateWindow
        }
      deltaX = abs (pixelCoordinateWindow.rightX - pixelCoordinateWindow.leftX)
      deltaY = abs (pixelCoordinateWindow.topY - pixelCoordinateWindow.bottomY)
  in
    if (testZoom < 1) then
      result
    else if (deltaX < window.width && deltaY < window.height) then
      result
    else 
      getZoomRecursiveHelper (testZoom - 1) window geoCoordinateWindow

  
-- calculates amount of available tiles along x OR y axis for zoom
tilesFromZoom: Int -> Int
tilesFromZoom zoom = 
  2 ^ zoom

getTileRange: PixelCoordinateWindow -> Int -> TileRange
getTileRange pixelCoordinateWindow zoom = 
  let
    leftX = toFloat pixelCoordinateWindow.leftX
    rightX = toFloat pixelCoordinateWindow.rightX
    topY = toFloat pixelCoordinateWindow.topY
    bottomY = toFloat pixelCoordinateWindow.bottomY
    xTileLeft = (Basics.floor ( leftX / tilePixelSize )) - 1
    xTileRight = (Basics.ceiling ( rightX / tilePixelSize )) + 1
    yTileTop = (Basics.floor ( topY / tilePixelSize )) - 1
    yTileBottom = (Basics.ceiling ( bottomY / tilePixelSize )) + 1
  in
    { rangeX = List.range xTileLeft xTileRight
    , rangeY = List.range yTileTop yTileBottom
    }


getPixelCenterFromWindow: PixelCoordinateWindow -> PixelCoordinatePoint
getPixelCenterFromWindow window = 
  { x = (window.leftX + window.rightX) // 2
  , y = (window.topY + window.bottomY) // 2
  }

pixelPointToGeoPointCoordinates: Int -> PixelCoordinatePoint -> GeoCoordinatePoint
pixelPointToGeoPointCoordinates zoom pixelPoint = 
  { long = ProjectionWebMercator.xToLong pixelPoint.x zoom
  , lat = ProjectionWebMercator.yToLat pixelPoint.y zoom
  }
geoPoinCoordinatesToPixelPoint: Int -> GeoCoordinatePoint -> PixelCoordinatePoint
geoPoinCoordinatesToPixelPoint zoom geoPoint = 
      { x = round (ProjectionWebMercator.longToX geoPoint.long zoom)
      , y = round (ProjectionWebMercator.latToY geoPoint.lat zoom)
      }

transformPixelToGeoCoordinateWindow: Int -> PixelCoordinateWindow -> GeoCoordinateWindow
transformPixelToGeoCoordinateWindow zoom pixelCoordinateWindow =
  { longLeft = ProjectionWebMercator.xToLong pixelCoordinateWindow.leftX zoom
  , longRight = ProjectionWebMercator.xToLong pixelCoordinateWindow.rightX zoom
  , latTop = ProjectionWebMercator.yToLat pixelCoordinateWindow.topY zoom
  , latBottom = ProjectionWebMercator.yToLat pixelCoordinateWindow.bottomY zoom
  }

getPixelCoordinateWindowHelper: Int -> GeoCoordinateWindow -> PixelCoordinateWindow
getPixelCoordinateWindowHelper zoom geoCoordinateWindow = 
  { leftX = round (ProjectionWebMercator.longToX geoCoordinateWindow.longLeft zoom)
  , rightX = round (ProjectionWebMercator.longToX geoCoordinateWindow.longRight zoom)
  , topY = round (ProjectionWebMercator.latToY geoCoordinateWindow.latTop zoom)
  , bottomY = round (ProjectionWebMercator.latToY geoCoordinateWindow.latBottom zoom) 
  }


type alias TileRange = 
  { rangeX: List Int
  , rangeY: List Int
  }

type alias CompleteMapConfiguration =
  { window: Window
  , zoom: Int
  , initialGeoCoordinateWindow: GeoCoordinateWindow
  , finalGeoCoordinateWindow: GeoCoordinateWindow
  , initialPixelCoordinateWindow: PixelCoordinateWindow
  , finalPixelCoordinateWindow: PixelCoordinateWindow
  , tileRange: TileRange
  }

getCompleteMapConfigurationFromWindowAndGeoCoordinateWindow: Window -> GeoCoordinateWindow -> CompleteMapConfiguration
getCompleteMapConfigurationFromWindowAndGeoCoordinateWindow window geoCoordinateWindow = 
  let
    zoomPlusPixel = getZoom window geoCoordinateWindow
    adaptedPixelCoordinateWindow = adaptPixelCoordinateWindowForWindow window zoomPlusPixel.pixelCoordinateWindow
    newGeo = transformPixelToGeoCoordinateWindow zoomPlusPixel.zoom adaptedPixelCoordinateWindow
  in
    { window = window
    , zoom = zoomPlusPixel.zoom
    , initialGeoCoordinateWindow = geoCoordinateWindow
    , finalGeoCoordinateWindow = newGeo
    , initialPixelCoordinateWindow = zoomPlusPixel.pixelCoordinateWindow
    , finalPixelCoordinateWindow = adaptedPixelCoordinateWindow
    , tileRange = getTileRange adaptedPixelCoordinateWindow zoomPlusPixel.zoom
    }


adaptPixelCoordinateWindowForWindow: Window -> PixelCoordinateWindow -> PixelCoordinateWindow
adaptPixelCoordinateWindowForWindow window pixelCoordinateWindow = 
  let
    pixelCoordinateWindowWidth = toFloat (abs (pixelCoordinateWindow.rightX - pixelCoordinateWindow.leftX))
    pixelCoordinateWindowHeight = toFloat (abs (pixelCoordinateWindow.topY - pixelCoordinateWindow.bottomY))
    halfDeltaX = ((toFloat window.width) - pixelCoordinateWindowWidth) / 2
    halfDeltaY = ((toFloat window.height) - pixelCoordinateWindowHeight) / 2
  in
    {
      topY =  (pixelCoordinateWindow.topY - (round halfDeltaY)),
      bottomY = (pixelCoordinateWindow.bottomY + (round halfDeltaY)),
      leftX =  (pixelCoordinateWindow.leftX - (round halfDeltaX)),
      rightX = (pixelCoordinateWindow.rightX + (round halfDeltaX))
    }


panPixelCoordinateWindow: PixelCoordinateWindow -> Window -> Float -> Float -> Int -> PixelCoordinateWindow
panPixelCoordinateWindow coordinates window xFloat yFloat zoom = 
  let 
    x = round xFloat
    y = round yFloat
    maxBottomY = tilePixelSize * (tilesFromZoom zoom)
    result = 
      {
        leftX = coordinates.leftX - x
      , rightX = coordinates.rightX - x
      , topY = coordinates.topY - y
      , bottomY = coordinates.bottomY - y
      }
  in
    if result.topY < 0 then
      { result
      | topY = 0
      , bottomY = window.height
      }
    else if (result.topY + window.height) > maxBottomY then --bottomY > maxBottomY then
      { result
      | topY = maxBottomY - window.height
      , bottomY = maxBottomY
      }
    else
      result
