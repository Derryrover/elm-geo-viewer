module MapLayerDeeperZoom exposing (..)

import Html.Attributes exposing (style, class,value, src, alt, id)
import Browser exposing(element)
import Html exposing (..)
import Html.Keyed exposing(node)

import ElmStyle
import Types

keyedDiv = node "div"

mapLayer model tileUrl = 
  let
    maxTilesOnAxis = Types.tilesFromZoom (model.map.zoom + 1)
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