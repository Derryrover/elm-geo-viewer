module MapLayerDeeperZoom exposing(..)

import Html.Attributes exposing (style, class,value, src, alt, id)
import Html exposing (..)
import Html.Keyed
import List

import ElmStyle
import Types
import MapLayer
import ZoomLevel


keyedDiv = Html.Keyed.node "div"

createKey x y = "keyed_str_x_y_"++(String.fromInt x) ++ "_"++(String.fromInt y)

flatten2D : List (List a) -> List a
flatten2D list =
  List.foldr (++) [] list

mapLayer map createTileUrl zoomMinus = 
  let
    relativeZoom = 2 ^ (-zoomMinus)
    maxTilesOnAxis = Types.tilesFromZoom map.zoom
    mapZoomed = (ZoomLevel.updateWholeMapForZoom 
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
                } })
  in
    div 
      (ElmStyle.createStyleList 
        [ 
          ("position", "absolute")
        , ("pointer-events", "none")
        , ("transform", "scale(" ++ (String.fromInt relativeZoom) ++ ")")
        ] 
      )
      [keyedDiv 
          (ElmStyle.createStyleList 
            [ ("position", "absolute")
            , ("top", ElmStyle.intToPxString -(mapZoomed.finalPixelCoordinateWindow.topY))
            , ("left", ElmStyle.intToPxString -(mapZoomed.finalPixelCoordinateWindow.leftX))
            , ("pointer-events", "none")
            ] 
          )
           (flatten2D 
            ( List.map (\y ->
                List.map (\x ->
                  ( createKey x y 
                  , MapLayer.imageDiv mapZoomed createTileUrl x y 
                  )) 
                  mapZoomed.tileRange.rangeX
                )
              mapZoomed.tileRange.rangeY
            ))
            ]