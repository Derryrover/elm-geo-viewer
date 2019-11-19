module MapLayer exposing(..)

import Html.Attributes exposing (style, class,value, src, alt, id)
import Html exposing (..)
import Html.Keyed
import List

import ElmStyle
import Types

keyedDiv = Html.Keyed.node "div"

createKey x y = "keyed_str_x_y_"++(String.fromInt x) ++ "_"++(String.fromInt y)

flatten2D : List (List a) -> List a
flatten2D list =
  List.foldr (++) [] list

mapLayer model createTileUrl = 
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
           (flatten2D 
            ( List.map (\y ->
                List.map (\x ->
                  ( createKey x y 
                  , imageDiv model createTileUrl x y 
                  )) 
                  model.map.tileRange.rangeX
                )
              model.map.tileRange.rangeY
            ))

imageDiv model createTileUrl x y = 
  let
    maxTilesOnAxis = Types.tilesFromZoom model.map.zoom
    xMod = modBy maxTilesOnAxis x
    yMod = modBy maxTilesOnAxis y
    url = createTileUrl model.map.zoom xMod yMod
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