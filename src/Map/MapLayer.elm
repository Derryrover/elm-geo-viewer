module MapLayer exposing(..)

import Html.Attributes exposing (style, class,value, src, alt, id)
import Html exposing (..)
import Html.Keyed
import List

import ElmStyle
import Types
import ZoomLevel

import Svg
import Svg.Attributes
import Svg.Keyed
import MapVariables exposing (maxZoomLevel, tilePixelSize)


keyedSvg = Svg.Keyed.node "svg"
keyedSvgG = Svg.Keyed.node "g"
-- keyedSvgImage = Svg.Keyed.node "image"

keyedDiv = Html.Keyed.node "div"

createKey x y zoom = "keyed_str_x_y_"++(String.fromInt x) ++ "_"++(String.fromInt y) ++ "_" ++ (String.fromInt zoom)

flatten2D : List (List a) -> List a
flatten2D list =
  List.foldr (++) [] list

mapLayer map createMapBoxUrl = 
  keyedDiv 
      (ElmStyle.createStyleList 
            [ ("position", "absolute")
            , ("pointer-events", "none")])
      (List.map 
        (\zoomLevel -> mapLayerZoom map createMapBoxUrl zoomLevel )
        [-2,-1,0,1]
      )

mapLayerZoom map createTileUrl zoomMinus = 
  let
    mapZoomed = ZoomLevel.newMapForMinusZoom map zoomMinus
    zoomFactor = 2 ^ (maxZoomLevel - (map.zoom + zoomMinus))
  in
    ( (String.fromInt (map.zoom + zoomMinus) ) -- KEY FOR ZOOM LAYER
    , div 
      (ElmStyle.createStyleList 
        [ 
          ("position", "absolute")
        , ("pointer-events", "none")
        ] 
      )
      [
        mapLayerTiles mapZoomed map createTileUrl zoomFactor
            ])

mapLayerTiles map mapOriginal createTileUrl zoomFactor = 
  --  keyedDiv
    Svg.svg 
      [
        Svg.Attributes.viewBox 
          ( 
            ( String.fromInt ( map.finalPixelCoordinateWindow.leftX  * zoomFactor) ) ++ " " ++
            ( String.fromInt ( map.finalPixelCoordinateWindow.topY * zoomFactor) )  ++ " " ++
            ( String.fromInt ( map.window.width * zoomFactor  ))  ++ " " ++
            ( String.fromInt ( map.window.height * zoomFactor ))
          )
      , Svg.Attributes.width (String.fromInt mapOriginal.window.width)
      , Svg.Attributes.height (String.fromInt mapOriginal.window.height)
      ]
      [keyedSvgG [] 
           (flatten2D 
            ( List.map (\y ->
                List.map (\x ->
                  ( createKey x y map.zoom 
                  , imageDiv map createTileUrl zoomFactor x y 
                  )) 
                  map.tileRange.rangeX
                )
              map.tileRange.rangeY
            ))
      ]

imageDiv map createTileUrl zoomFactor x y = 
  let
    maxTilesOnAxis = Types.tilesFromZoom map.zoom
    xMod = modBy maxTilesOnAxis x
    yMod = modBy maxTilesOnAxis y
    url = createTileUrl map.zoom xMod yMod
  in
    -- div
    Svg.image 
      [
        Svg.Attributes.xlinkHref url
      , Svg.Attributes.x (String.fromInt (zoomFactor * tilePixelSize  * ( x)))
      , Svg.Attributes.y (String.fromInt (zoomFactor * tilePixelSize * ( y)))
      , Svg.Attributes.width (String.fromInt (zoomFactor * tilePixelSize))
      , Svg.Attributes.height (String.fromInt (zoomFactor * tilePixelSize))
      ]
      []

