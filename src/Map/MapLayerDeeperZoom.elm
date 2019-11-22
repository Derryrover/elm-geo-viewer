module MapLayerDeeperZoom exposing(..)

import Html.Attributes exposing (style, class,value, src, alt, id)
import Html exposing (..)
import Html.Keyed
import List

import ElmStyle
import Types
import MapLayer

keyedDiv = Html.Keyed.node "div"

createKey x y = "keyed_str_x_y_"++(String.fromInt x) ++ "_"++(String.fromInt y)

flatten2D : List (List a) -> List a
flatten2D list =
  List.foldr (++) [] list

mapLayer map createTileUrl relativeZoom = 
  let
    maxTilesOnAxis = Types.tilesFromZoom map.zoom
  in
    div 
      (ElmStyle.createStyleList 
        [ 
        --   ("position", "absolute")
        -- -- , ("top", ElmStyle.intToPxString (round ( toFloat (-model.map.finalPixelCoordinateWindow.topY) * 2)))
        -- -- , ("left", ElmStyle.intToPxString (round (toFloat (-model.map.finalPixelCoordinateWindow.leftX) * 2)))
        -- , ("top", ElmStyle.intToPxString -model.map.finalPixelCoordinateWindow.topY)
        -- , ("left", ElmStyle.intToPxString -model.map.finalPixelCoordinateWindow.leftX)
          ("position", "absolute")
        , ("top", (ElmStyle.intToPxString -(map.window.height // relativeZoom)))
        , ("left", (ElmStyle.intToPxString -(map.window.width // relativeZoom)))
        , ("pointer-events", "none")
        , ("transform", "scale("++ (String.fromInt relativeZoom) ++")")
        ] 
      )
      [keyedDiv 
          (ElmStyle.createStyleList 
            [ ("position", "absolute")
            -- , ("top", ElmStyle.intToPxString (round ( toFloat (-model.map.finalPixelCoordinateWindow.topY) * 2)))
            -- , ("left", ElmStyle.intToPxString (round (toFloat (-model.map.finalPixelCoordinateWindow.leftX) * 2)))
            , ("top", ElmStyle.intToPxString -map.finalPixelCoordinateWindow.topY)
            , ("left", ElmStyle.intToPxString -map.finalPixelCoordinateWindow.leftX)
            , ("pointer-events", "none")
            -- , ("transform", "scale(2)")
            ] 
          )
           (flatten2D 
            ( List.map (\y ->
                List.map (\x ->
                  ( createKey x y 
                  , MapLayer.imageDiv map createTileUrl x y 
                  )) 
                  map.tileRange.rangeX
                )
              map.tileRange.rangeY
            ))]

-- imageDiv model createTileUrl x y = 
--   let
--     maxTilesOnAxis = Types.tilesFromZoom model.map.zoom
--     xMod = modBy maxTilesOnAxis x
--     yMod = modBy maxTilesOnAxis y
--     url = createTileUrl model.map.zoom xMod yMod
--   in
--     div
--       ( ElmStyle.createStyleList 
--                 [ ("position", "absolute")
--                 , ("top", ElmStyle.intToPxString (Types.tilePixelSize * y))
--                 , ("left", ElmStyle.intToPxString (Types.tilePixelSize * x)) 
--                 ])
--       [ img
--         [ src url]
--         []]


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


{-
  var img = new Image();
    img.src = "http://tile.stamen.com/terrain-background/7/66/42.png";
    var complete = img.complete;
    img.src = "";
    console.log("complete", complete);

    - pass a list of old zoom levels from map
    - store a list of all images per zoom level and if they are loaded
    - if all images for newest zoom levels are loaded send message to map that old zoom levels do not need to be passed anymore

    - edit 
    - store a list of currently needed images and if they are loaded (probably passed via an update function on map)
    - onload event of images update this list that the image is loaded
    - also store a second list of all images that were ever requested (also for old zoom levels)
    - as soon as they are loaded mark the img in second list as loaded
    - anytime new img from second list is loaded all imgs from second list that were already loaded can be removed
    - when zoom /pan level changes show to begin also all other (or -2 and plus 2 ? ) zoom levels beneath it
    - as soon as currentzoom is completely loaded remove them
    - do not always load the old zoom. check in webcomponent with above javascript if it can be loaded from cache if not show transparent div
    -
-}