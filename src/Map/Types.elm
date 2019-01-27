module Types exposing (..)

import ProjectionWebMercator
import Maybe exposing(..)

type alias Window = 
  { width: Int
  , height: Int
  }

type alias GeoCoordinates = 
  { longLeft: Float
  , longRight: Float
  , latTop: Float
  , latBottom: Float
  }

type alias PixelCoordinates =
  { leftX: Int
  , rightX: Int
  , topY: Int
  , bottomY: Int 
  }

type alias ZoomPlusPixel = 
  { zoom: Int
  , pixelCoordinates: PixelCoordinates
  }

type alias CompleteMapConfiguration =
  { window: Window
  , zoom: Int
  , initialGeoCoordinates: GeoCoordinates
  , finalGeoCoordinates: GeoCoordinates
  , initialPixelCoordinates: PixelCoordinates
  , finalPixelCoordinates: PixelCoordinates
  }

getCompleteMapConfigurationFromWindowAndGeoCoordinates: Window -> GeoCoordinates -> CompleteMapConfiguration
getCompleteMapConfigurationFromWindowAndGeoCoordinates window geoCoordinates = 
  let
    zoomPlusPixel = mapSettingsToZoomAndPixelCoordinates window geoCoordinates
    adaptedPixelCoordinates = adaptPixelCoordinatesForWindow window zoomPlusPixel.pixelCoordinates
    newGeo = transformPixelToGeoCoordinates zoomPlusPixel.zoom adaptedPixelCoordinates
  in
    { window = window
    , zoom = zoomPlusPixel.zoom
    , initialGeoCoordinates = geoCoordinates
    , finalGeoCoordinates = newGeo
    , initialPixelCoordinates = zoomPlusPixel.pixelCoordinates
    , finalPixelCoordinates = adaptedPixelCoordinates
    }

mapSettingsToZoomAndPixelCoordinates: Window -> GeoCoordinates -> ZoomPlusPixel
mapSettingsToZoomAndPixelCoordinates window geoCoordinates = 
  let 
    maybeZoomCoordinates = getZoomLevelHelper 0 window geoCoordinates
  in
    case maybeZoomCoordinates of
      Nothing -> -- return dummie value cry cry. this should never happen. Should we throw error ?
        { zoom = 1
        , pixelCoordinates = 
          { leftX = 1
          , rightX = 2
          , topY = 1
          , bottomY = 2 
          }
        }
      Just result ->
        result

maxZoomLevel = 16

getPixelCoordinatesHelper: Int -> GeoCoordinates -> PixelCoordinates
getPixelCoordinatesHelper zoom geoCoordinates = 
  { leftX = round (ProjectionWebMercator.longToX geoCoordinates.longLeft zoom)
  , rightX = round (ProjectionWebMercator.longToX geoCoordinates.longRight zoom)
  , topY = round (ProjectionWebMercator.latToY geoCoordinates.latTop zoom)
  , bottomY = round (ProjectionWebMercator.latToY geoCoordinates.latBottom zoom) 
  }

-- always call with teszoom=0 , function will call itself recursive with higher testzoom untill it finds correct zoom or untill maxZoomLevel is reached
getZoomLevelHelper: Int -> Window -> GeoCoordinates -> Maybe ZoomPlusPixel
getZoomLevelHelper testZoom window geoCoordinates  = 
  let
    pixelCoordinates = getPixelCoordinatesHelper testZoom geoCoordinates
    deltaX = abs (pixelCoordinates.rightX - pixelCoordinates.leftX)
    deltaY = abs (pixelCoordinates.topY - pixelCoordinates.bottomY)
  in
    if (deltaX > window.width && deltaY > window.height) then -- current scale is too big to fit in window
      if testZoom == 0 then -- is already smallest zoom -> return smallest zoom 
        Just  { zoom = 0
              , pixelCoordinates = pixelCoordinates
              }
      else -- zoom level to high -> return fail
        Nothing
    else if testZoom == maxZoomLevel then -- map bigger then maximum resolution zoomlevel
      Just  { zoom = maxZoomLevel
            , pixelCoordinates = pixelCoordinates
            } 
    else -- zoom level maybe not yet high enough check next zoomlevel
      let
        testBiggerZoom = getZoomLevelHelper (testZoom+1) window geoCoordinates
      in
        case testBiggerZoom of 
          Nothing ->
            Just  { zoom = testZoom
                  , pixelCoordinates = pixelCoordinates
                  }
          Just result ->
            Just result

adaptPixelCoordinatesForWindow: Window -> PixelCoordinates -> PixelCoordinates
adaptPixelCoordinatesForWindow window pixelCoordinates = 
  let
    deltaX = toFloat (abs (pixelCoordinates.rightX - pixelCoordinates.leftX))
    deltaY = toFloat (abs (pixelCoordinates.topY - pixelCoordinates.bottomY))
    relativeWidthHeight = (toFloat window.height) / (toFloat window.width)
    relativeLongLat =  deltaY / deltaX
  in
    if (relativeLongLat < relativeWidthHeight) then -- coordinates are wider
      let
        width = deltaY / relativeWidthHeight
        halfWidthDelta = (width - deltaX) / 2
        xLeftNew = pixelCoordinates.leftX - ( round halfWidthDelta)
        xRightNew = pixelCoordinates.rightX + ( round halfWidthDelta)
      in
        { pixelCoordinates |
            leftX = xLeftNew,
            rightX = xRightNew
        }
    else 
      let
        height = deltaX * relativeLongLat
        halfheightDelta = (height - deltaY) / 2
        yTopNew = pixelCoordinates.topY - ( round halfheightDelta)
        yBottomNew = pixelCoordinates.bottomY + ( round halfheightDelta)
      in
        { pixelCoordinates |
            topY = yTopNew,
            bottomY = yBottomNew
        }
  -- { leftX = 1
  -- , rightX = 2
  -- , topY = 1
  -- , bottomY = 2 
  -- }

transformPixelToGeoCoordinates: Int -> PixelCoordinates -> GeoCoordinates
transformPixelToGeoCoordinates zoom pixelCoordinates =
  { longLeft = ProjectionWebMercator.xToLong pixelCoordinates.leftX zoom
  , longRight = ProjectionWebMercator.xToLong pixelCoordinates.rightX zoom
  , latTop = ProjectionWebMercator.yToLat pixelCoordinates.topY zoom
  , latBottom = ProjectionWebMercator.yToLat pixelCoordinates.bottomY zoom
  }


  