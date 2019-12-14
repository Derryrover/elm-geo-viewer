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
    [
        -- mapLayerZoom 
        --   map
        --   createMapBoxUrl
        --   -4
        -- , 
        -- mapLayerZoom 
        --   map
        --   createMapBoxUrl
        --   -3
        -- , mapLayerZoom 
        --   map
        --   createMapBoxUrl
        --   -2
        -- , 
        mapLayerZoom 
          map
          createMapBoxUrl
          -1
        , 
        mapLayerZoom 
          map
          createMapBoxUrl
          0
        , 
        mapLayerZoom 
          map
          createMapBoxUrl
          1
        -- ,
        -- mapLayerZoom 
        --   map
        --   createMapBoxUrl
        --   2
    ]

mapLayerZoom map createTileUrl zoomMinus = 
  let
    mapZoomed = newMapForMinusZoom map zoomMinus
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

-- [ ("position", "absolute")
-- , ("top", ElmStyle.intToPxString (MapVariables.tilePixelSize * y))
-- , ("left", ElmStyle.intToPxString (MapVariables.tilePixelSize * x)) 
-- , ("height", ElmStyle.intToPxString MapVariables.tilePixelSize)
-- , ("width", ElmStyle.intToPxString MapVariables.tilePixelSize)
-- ])

  -- [ img
  --       (List.concat [ 
  --         [ (src (tileUrl model.map.zoom (modBy maxTilesOnAxis x) (modBy maxTilesOnAxis y)))]
  --       , ( ElmStyle.createStyleList 
  --           [ ("height", "100%")
  --           , ("width", "100%") ]
  --         )])
  --       [] ]

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


newMapForMinusZoom map zoomMinus = 
  let
      relativeZoom = 2 ^ (-zoomMinus)
  in
  
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

