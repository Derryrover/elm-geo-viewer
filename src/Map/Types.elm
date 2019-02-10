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

type alias TileRange = 
  { rangeX: List Int
  , rangeY: List Int
  , panFromLeft: Int
  , panFromTop: Int 
  }

type alias CompleteMapConfiguration =
  { window: Window
  , zoom: Int
  , initialGeoCoordinates: GeoCoordinates
  , finalGeoCoordinates: GeoCoordinates
  , initialPixelCoordinates: PixelCoordinates
  , finalPixelCoordinates: PixelCoordinates
  , tileRange: TileRange
  }

-- type alias MapConfigurationForView = 
--   { window: Window
--   , zoom: Int
--   , geoCoordinates: GeoCoordinates
--   , pixelCoordinates: PixelCoordinates
--   , tileRange: TileRange
--   }




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
    , tileRange = getTileRange adaptedPixelCoordinates zoomPlusPixel.zoom
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
    if (deltaX > window.width || deltaY > window.height) then -- current scale is too big to fit in window
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
    if (relativeLongLat > relativeWidthHeight) then -- coordinates are wider
      let
        width = deltaY / relativeWidthHeight
        halfWidthDelta = (abs (width - deltaX)) / 2
        xLeftNew = pixelCoordinates.leftX - ( round halfWidthDelta)
        xRightNew = pixelCoordinates.rightX + ( round halfWidthDelta)
      in
        { pixelCoordinates |
            leftX = xLeftNew,
            rightX = xRightNew
        }
    else 
      let
        height = deltaX * relativeWidthHeight
        halfheightDelta = (abs(height - deltaY)) / 2
        yTopNew = pixelCoordinates.topY - ( round halfheightDelta)
        yBottomNew = pixelCoordinates.bottomY + ( round halfheightDelta)
      in
        { pixelCoordinates |
            topY = yTopNew,
            bottomY = yBottomNew
        }

panPixelCoordinates: PixelCoordinates -> Window -> Float -> Float -> Int -> PixelCoordinates
panPixelCoordinates coordinates window xFloat yFloat zoom = 
  let 
    x = round xFloat
    y = round yFloat
    leftX = coordinates.leftX - x
    rightX = coordinates.rightX - x
    topY = coordinates.topY - y
    bottomY = coordinates.bottomY - y
    maxBottomY = 256 * (tilesFromZoom zoom)
  in
    if topY < 0 then
      { leftX = coordinates.leftX - x
      , rightX = coordinates.rightX - x
      , topY = 0
      , bottomY = window.height
      }
    else if (topY + window.height) > maxBottomY then --bottomY > maxBottomY then
      { leftX = coordinates.leftX - x
      , rightX = coordinates.rightX - x
      , topY = maxBottomY - window.height
      , bottomY = maxBottomY
      }
    else
      { leftX = coordinates.leftX - x
      , rightX = coordinates.rightX - x
      , topY = coordinates.topY - y
      , bottomY = coordinates.bottomY - y
      }




transformPixelToGeoCoordinates: Int -> PixelCoordinates -> GeoCoordinates
transformPixelToGeoCoordinates zoom pixelCoordinates =
  { longLeft = ProjectionWebMercator.xToLong pixelCoordinates.leftX zoom
  , longRight = ProjectionWebMercator.xToLong pixelCoordinates.rightX zoom
  , latTop = ProjectionWebMercator.yToLat pixelCoordinates.topY zoom
  , latBottom = ProjectionWebMercator.yToLat pixelCoordinates.bottomY zoom
  }

getTileRange: PixelCoordinates -> Int -> TileRange
getTileRange pixelCoordinates zoom = 
  let
    leftX = toFloat pixelCoordinates.leftX
    rightX = toFloat pixelCoordinates.rightX
    topY = toFloat pixelCoordinates.topY
    bottomY = toFloat pixelCoordinates.bottomY
    xTileLeft = (Basics.floor ( leftX / 256 )) - 1
    xTileRight = (Basics.ceiling ( rightX / 256 )) + 1
    yTileTop = (Basics.floor ( topY / 256 )) - 1
    yTileBottom = (Basics.ceiling ( bottomY / 256 )) + 1
    amountTiles = tilesFromZoom zoom
  in
    { rangeX = List.range xTileLeft xTileRight--getTileRangeHelper xTileLeft xTileRight amountTiles --List.range xTileLeft xTileRight
    , rangeY = List.range yTileTop yTileBottom --amountTiles
    , panFromLeft = (modBy 256 pixelCoordinates.leftX) -- + 256 -- is this still used ?
    , panFromTop = (modBy 256 pixelCoordinates.topY) -- + 256 -- is this still used ?
    }

getTileRangeHelper min max maxTiles =
  let
    preZeroRange = 
      if min < 0 then
        let 
          preZero = maxTiles + min
        in 
          List.range preZero maxTiles
      else
        []
    normalRange = List.range min max
    normalRangeFilteredZero = List.filter (\n-> -1 < n) normalRange
    normalRangeFiltered = List.filter (\n-> n < maxTiles) normalRangeFilteredZero
    postMaxRange = 
      if max >= maxTiles then
        let 
          postNormal = max - maxTiles
        in
          List.range postNormal (maxTiles - 1) 
      else
        []
  in
    List.concat [preZeroRange, normalRangeFiltered, postMaxRange]
  
  


tilesFromZoom: Int -> Int
tilesFromZoom zoom = 
  case zoom of 
    0 ->
      1
    1 ->
      2
    other ->
      2 * (tilesFromZoom (other - 1))
  -- (zoom + 1) ^ 2
  --zoom ^ 2
