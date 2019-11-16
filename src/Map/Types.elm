module Types exposing (..)

import ProjectionWebMercator
-- import Maybe exposing(..)

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



type alias ZoomPlusPixel = 
  { zoom: Int
  , pixelCoordinateWindow: PixelCoordinateWindow
  }

type alias TileRange = 
  { rangeX: List Int
  , rangeY: List Int
  -- , panFromLeft: Int
  -- , panFromTop: Int 
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

-- type alias MapConfigurationForView = 
--   { window: Window
--   , zoom: Int
--   , geoCoordinateWindow: GeoCoordinateWindow
--   , PixelCoordinateWindow: PixelCoordinateWindow
--   , tileRange: TileRange
--   }




getCompleteMapConfigurationFromWindowAndGeoCoordinateWindow: Window -> GeoCoordinateWindow -> CompleteMapConfiguration
getCompleteMapConfigurationFromWindowAndGeoCoordinateWindow window geoCoordinateWindow = 
  let
    -- zoomPlusPixel = mapSettingsToZoomAndPixelCoordinateWindow window geoCoordinateWindow
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

-- mapSettingsToZoomAndPixelCoordinateWindow: Window -> GeoCoordinateWindow -> ZoomPlusPixel
-- mapSettingsToZoomAndPixelCoordinateWindow window geoCoordinateWindow = 
--   let 
--     maybeZoomCoordinates = getZoomLevelHelper 0 window geoCoordinateWindow
--   in
--     case maybeZoomCoordinates of
--       Nothing -> -- return dummie value cry cry. this should never happen. Should we throw error ?
--         { zoom = 1
--         , pixelCoordinateWindow = 
--           { leftX = 1
--           , rightX = 2
--           , topY = 1
--           , bottomY = 2 
--           }
--         }
--       Just result ->
--         result



getPixelCoordinateWindowHelper: Int -> GeoCoordinateWindow -> PixelCoordinateWindow
getPixelCoordinateWindowHelper zoom geoCoordinateWindow = 
  { leftX = round (ProjectionWebMercator.longToX geoCoordinateWindow.longLeft zoom)
  , rightX = round (ProjectionWebMercator.longToX geoCoordinateWindow.longRight zoom)
  , topY = round (ProjectionWebMercator.latToY geoCoordinateWindow.latTop zoom)
  , bottomY = round (ProjectionWebMercator.latToY geoCoordinateWindow.latBottom zoom) 
  }

maxZoomLevel = 16

getZoom: Window -> GeoCoordinateWindow -> ZoomPlusPixel
getZoom window geoCoordinateWindow = 
  getZoomRecursiveHelper maxZoomLevel window geoCoordinateWindow

getZoomRecursiveHelper: Int -> Window -> GeoCoordinateWindow -> ZoomPlusPixel
getZoomRecursiveHelper testZoom window geoCoordinateWindow = 
  let
      pixelCoordinateWindow = getPixelCoordinateWindowHelper testZoom geoCoordinateWindow
      deltaX = abs (pixelCoordinateWindow.rightX - pixelCoordinateWindow.leftX)
      deltaY = abs (pixelCoordinateWindow.topY - pixelCoordinateWindow.bottomY)
  in
    if (deltaX > window.width || deltaY > window.height) then
      getZoomRecursiveHelper (testZoom - 1) window geoCoordinateWindow
    else 
      { zoom = testZoom
      , pixelCoordinateWindow = pixelCoordinateWindow
      }

  


-- always call with teszoom=0 , function will call itself recursive with higher testzoom untill it finds correct zoom or untill maxZoomLevel is reached
-- getZoomLevelHelper: Int -> Window -> GeoCoordinateWindow -> Maybe ZoomPlusPixel
-- getZoomLevelHelper testZoom window geoCoordinateWindow  = 
--   let
--     pixelCoordinateWindow = getPixelCoordinateWindowHelper testZoom geoCoordinateWindow
--     deltaX = abs (pixelCoordinateWindow.rightX - pixelCoordinateWindow.leftX)
--     deltaY = abs (pixelCoordinateWindow.topY - pixelCoordinateWindow.bottomY)
--   in
--     if (deltaX > window.width || deltaY > window.height) then -- current scale is too big to fit in window
--       if testZoom == 0 then -- is already smallest zoom -> return smallest zoom 
--         Just  { zoom = 0
--               , pixelCoordinateWindow = pixelCoordinateWindow
--               }
--       else -- zoom level to high -> return fail
--         Nothing
--     else if testZoom == maxZoomLevel then -- map bigger then maximum resolution zoomlevel
--       Just  { zoom = maxZoomLevel
--             , pixelCoordinateWindow = pixelCoordinateWindow
--             } 
--     else -- zoom level maybe not yet high enough check next zoomlevel
--       let
--         testBiggerZoom = getZoomLevelHelper (testZoom+1) window geoCoordinateWindow
--       in
--         case testBiggerZoom of 
--           Nothing ->
--             Just  { zoom = testZoom
--                   , pixelCoordinateWindow = pixelCoordinateWindow
--                   }
--           Just result ->
--             Just result

adaptPixelCoordinateWindowForWindow: Window -> PixelCoordinateWindow -> PixelCoordinateWindow
adaptPixelCoordinateWindowForWindow window pixelCoordinateWindow = 
  let
    pixelCoordinateWindowWidth = toFloat (abs (pixelCoordinateWindow.rightX - pixelCoordinateWindow.leftX))
    pixelCoordinateWindowHeight = toFloat (abs (pixelCoordinateWindow.topY - pixelCoordinateWindow.bottomY))
    halfDeltaX = ((toFloat window.width) - pixelCoordinateWindowWidth) / 2
    halfDeltaY = ((toFloat window.height) - pixelCoordinateWindowHeight) / 2
    -- relativeWidthHeight = (toFloat window.height) / (toFloat window.width)
    -- relativeLongLat =  deltaY / deltaX
  in
    {
      topY =  (pixelCoordinateWindow.topY - (round halfDeltaY)),
      bottomY = (pixelCoordinateWindow.bottomY + (round halfDeltaY)),
      leftX =  (pixelCoordinateWindow.leftX - (round halfDeltaX)),
      rightX = (pixelCoordinateWindow.rightX + (round halfDeltaX))
    }
  -- let
  --   deltaX = toFloat (abs (pixelCoordinateWindow.rightX - pixelCoordinateWindow.leftX))
  --   deltaY = toFloat (abs (pixelCoordinateWindow.topY - pixelCoordinateWindow.bottomY))
  --   relativeWidthHeight = (toFloat window.height) / (toFloat window.width)
  --   relativeLongLat =  deltaY / deltaX
  -- in
  --   if (relativeLongLat > relativeWidthHeight) then -- coordinates are wider
  --     let
  --       width = deltaY / relativeWidthHeight
  --       halfWidthDelta = (abs (width - deltaX)) / 2
  --       xLeftNew = pixelCoordinateWindow.leftX - ( round halfWidthDelta)
  --       xRightNew = pixelCoordinateWindow.rightX + ( round halfWidthDelta)
  --     in
  --       { pixelCoordinateWindow |
  --           leftX = xLeftNew,
  --           rightX = xRightNew
  --       }
  --   else 
  --     let
  --       height = deltaX * relativeWidthHeight
  --       halfheightDelta = (abs(height - deltaY)) / 2
  --       yTopNew = pixelCoordinateWindow.topY - ( round halfheightDelta)
  --       yBottomNew = pixelCoordinateWindow.bottomY + ( round halfheightDelta)
  --     in
  --       { pixelCoordinateWindow |
  --           topY = yTopNew,
  --           bottomY = yBottomNew
  --       }

panPixelCoordinateWindow: PixelCoordinateWindow -> Window -> Float -> Float -> Int -> PixelCoordinateWindow
panPixelCoordinateWindow coordinates window xFloat yFloat zoom = 
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




transformPixelToGeoCoordinateWindow: Int -> PixelCoordinateWindow -> GeoCoordinateWindow
transformPixelToGeoCoordinateWindow zoom pixelCoordinateWindow =
  { longLeft = ProjectionWebMercator.xToLong pixelCoordinateWindow.leftX zoom
  , longRight = ProjectionWebMercator.xToLong pixelCoordinateWindow.rightX zoom
  , latTop = ProjectionWebMercator.yToLat pixelCoordinateWindow.topY zoom
  , latBottom = ProjectionWebMercator.yToLat pixelCoordinateWindow.bottomY zoom
  }

getTileRange: PixelCoordinateWindow -> Int -> TileRange
getTileRange pixelCoordinateWindow zoom = 
  let
    leftX = toFloat pixelCoordinateWindow.leftX
    rightX = toFloat pixelCoordinateWindow.rightX
    topY = toFloat pixelCoordinateWindow.topY
    bottomY = toFloat pixelCoordinateWindow.bottomY
    xTileLeft = (Basics.floor ( leftX / 256 )) - 1
    xTileRight = (Basics.ceiling ( rightX / 256 )) + 1
    yTileTop = (Basics.floor ( topY / 256 )) - 1
    yTileBottom = (Basics.ceiling ( bottomY / 256 )) + 1
    -- amountTiles = tilesFromZoom zoom
  in
    { rangeX = List.range xTileLeft xTileRight--getTileRangeHelper xTileLeft xTileRight amountTiles --List.range xTileLeft xTileRight
    , rangeY = List.range yTileTop yTileBottom --amountTiles
    -- , panFromLeft = (modBy 256 pixelCoordinateWindow.leftX) -- + 256 -- is this still used ?
    -- , panFromTop = (modBy 256 pixelCoordinateWindow.topY) -- + 256 -- is this still used ?
    }

-- getTileRangeHelper min max maxTiles =
--   let
--     preZeroRange = 
--       if min < 0 then
--         let 
--           preZero = maxTiles + min
--         in 
--           List.range preZero maxTiles
--       else
--         []
--     normalRange = List.range min max
--     normalRangeFilteredZero = List.filter (\n-> -1 < n) normalRange
--     normalRangeFiltered = List.filter (\n-> n < maxTiles) normalRangeFilteredZero
--     postMaxRange = 
--       if max >= maxTiles then
--         let 
--           postNormal = max - maxTiles
--         in
--           List.range postNormal (maxTiles - 1) 
--       else
--         []
--   in
--     List.concat [preZeroRange, normalRangeFiltered, postMaxRange]
  
  

-- calculates amount of available tiles along x OR y axis for zoom
tilesFromZoom: Int -> Int
tilesFromZoom zoom = 
  2 ^ zoom
