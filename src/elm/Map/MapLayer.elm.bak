module MapLayer exposing(..)

import Html.Attributes exposing (style, class,value, src, alt, id)
import Browser exposing(element)
import Html exposing (..)
import Html.Keyed exposing(node)

import ElmStyle
import Types

keyedDiv = node "div"

mapLayer model tileUrl = 
  let
    maxTilesOnAxis = Types.tilesFromZoom model.map.zoom
  in
   keyedDiv 
          (ElmStyle.createStyleList 
            [ ("position", "absolute")
            , ("top", ElmStyle.intToPxString -model.map.finalPixelCoordinateWindow.topY)
            , ("left", ElmStyle.intToPxString -model.map.finalPixelCoordinateWindow.leftX)
            , ("pointer-events", "none")
            ] 
          )
          ( List.map (\y ->
            ( ("keyed_div_y_value_"++(String.fromInt y)) 
            , keyedDiv
              ( ElmStyle.createStyleList 
                  [ ("height", ElmStyle.intToPxString Types.tilePixelSize)
                  , ("position", "absolute")
                  , ("top", ElmStyle.intToPxString (Types.tilePixelSize * y))
                  ] 
              )
              (List.map (\x ->
                ( ("keyed_div_x_y_value_"++(String.fromInt x) ++ "_"++(String.fromInt y)) 
                , div
                ( ElmStyle.createStyleList 
                          [ ("height", ElmStyle.intToPxString Types.tilePixelSize)
                          , ("width", ElmStyle.intToPxString Types.tilePixelSize)
                          , ("position", "absolute")
                          , ("left", ElmStyle.intToPxString (Types.tilePixelSize * x)) ])
                [ img
                  (List.concat [ 
                    [ (src (tileUrl model.map.zoom (modBy maxTilesOnAxis x) (modBy maxTilesOnAxis y)))]
                  , ( ElmStyle.createStyleList 
                      [ ("height", "100%")
                      , ("width", "100%") ]
                    )])
                  [] ]
                )) 
                model.map.tileRange.rangeX
              )
          ))
          model.map.tileRange.rangeY
        )