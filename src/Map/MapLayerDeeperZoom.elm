module MapLayerDeeperZoom exposing(..)

import Html.Attributes exposing (style, class,value, src, alt, id)
import Html exposing (..)
import Html.Keyed
import List

import ElmStyle
import Types
import MapLayer
import ZoomLevel

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

mapLayer map createTileUrl zoomMinus = 
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
        MapLayer.mapLayerTiles mapZoomed createTileUrl
            ]