module MapLayer exposing(..)

import Html.Attributes exposing (style, class,value, src, alt, id)
import Html exposing (..)
import Html.Keyed
import List

import ElmStyle
import Types
import ZoomLevel


keyedDiv = Html.Keyed.node "div"

createKey x y = "keyed_str_x_y_"++(String.fromInt x) ++ "_"++(String.fromInt y)

flatten2D : List (List a) -> List a
flatten2D list =
  List.foldr (++) [] list

mapLayer map createMapBoxUrl = 
  div 
      (ElmStyle.createStyleList 
            [ ("position", "absolute")])
    [
        mapLayerZoom 
          map
          createMapBoxUrl
          -4
        , mapLayerZoom 
          map
          createMapBoxUrl
          -3
        , mapLayerZoom 
          map
          createMapBoxUrl
          -2
        , mapLayerZoom 
          map
          createMapBoxUrl
          -1
        , mapLayerZoom 
          map
          createMapBoxUrl
          0
    ]

mapLayerTiles map createTileUrl = 
   keyedDiv 
          (ElmStyle.createStyleList 
            [ ("position", "absolute")
            , ("top", ElmStyle.intToPxString -map.finalPixelCoordinateWindow.topY)
            , ("left", ElmStyle.intToPxString -map.finalPixelCoordinateWindow.leftX)
            , ("pointer-events", "none")
            ] 
          )
           (flatten2D 
            ( List.map (\y ->
                List.map (\x ->
                  ( createKey x y 
                  , imageDiv map createTileUrl x y 
                  )) 
                  map.tileRange.rangeX
                )
              map.tileRange.rangeY
            ))

imageDiv map createTileUrl x y = 
  let
    maxTilesOnAxis = Types.tilesFromZoom map.zoom
    xMod = modBy maxTilesOnAxis x
    yMod = modBy maxTilesOnAxis y
    url = createTileUrl map.zoom xMod yMod
  in
    div
      ( ElmStyle.createStyleList 
                [ ("position", "absolute")
                , ("top", ElmStyle.intToPxString (Types.tilePixelSize * y))
                , ("left", ElmStyle.intToPxString (Types.tilePixelSize * x)) 
                ])
      [ img
        [ src url]
        []]


newMapForMinusZoom map zoomMinus relativeZoom = 
  ZoomLevel.updateWholeMapForZoom 
            (map.zoom + zoomMinus)  
            { x = map.window.width // (relativeZoom*2)
            , y = map.window.height // (relativeZoom*2)}
            { map | 
              window =  {
                width = map.window.width // relativeZoom
              , height = map.window.height // relativeZoom  
              }
              , finalPixelCoordinateWindow = 
                let 
                  halfW = map.window.width // (relativeZoom*2)
                  halfH = map.window.height // (relativeZoom*2)
                  totalPixelHorizontal = (map.finalPixelCoordinateWindow.leftX + map.finalPixelCoordinateWindow.rightX) // 2
                  totalPixelVertical = (map.finalPixelCoordinateWindow.topY + map.finalPixelCoordinateWindow.bottomY) // 2
                in
                {
                    leftX = totalPixelHorizontal - halfW
                  , rightX = totalPixelHorizontal + halfW
                  , topY = totalPixelVertical - halfH
                  , bottomY = totalPixelVertical + halfH
                } }

mapLayerZoom map createTileUrl zoomMinus = 
  let
    relativeZoom = 2 ^ (-zoomMinus)
    mapZoomed = newMapForMinusZoom map zoomMinus relativeZoom
  in
    div 
      (ElmStyle.createStyleList 
        [ 
          ("position", "absolute")
        , ("pointer-events", "none")
        , ("transform", "scale(" ++ (String.fromInt relativeZoom) ++ ")")
        ] 
      )
      [
        mapLayerTiles mapZoomed createTileUrl
            ]

-- [ ("position", "absolute")
-- , ("top", ElmStyle.intToPxString (Types.tilePixelSize * y))
-- , ("left", ElmStyle.intToPxString (Types.tilePixelSize * x)) 
-- , ("height", ElmStyle.intToPxString Types.tilePixelSize)
-- , ("width", ElmStyle.intToPxString Types.tilePixelSize)
-- ])

  -- [ img
  --       (List.concat [ 
  --         [ (src (tileUrl model.map.zoom (modBy maxTilesOnAxis x) (modBy maxTilesOnAxis y)))]
  --       , ( ElmStyle.createStyleList 
  --           [ ("height", "100%")
  --           , ("width", "100%") ]
  --         )])
  --       [] ]