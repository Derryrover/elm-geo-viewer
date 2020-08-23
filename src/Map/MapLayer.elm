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
import MapVariables exposing (
  maxZoomLevel
  -- , tilePixelSize
  )

type Msg 
  = 
  TileLoaded Int Int Int

type alias Model = 
  { loadedTiles: List Int
  , a: Int
  }

init : () -> (Model, Cmd Msg)
init _ = 
  let 
    map = 1
    zoomFactor = 1
  in
    (
        { loadedTiles = []
        , a = 0
        }
      , Cmd.batch []
    )

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = 
  case msg of
    TileLoaded x y z -> 
      (
        { loadedTiles = []
        , a = 0
        }
      , Cmd.none
      ) 

tilePixelSize = 1--256


keyedSvg = Svg.Keyed.node "svg"
keyedSvgG = Svg.Keyed.node "g"


createKey x y zoom = "keyed_str_x_y_"++(String.fromInt x) ++ "_"++(String.fromInt y) ++ "_" ++ (String.fromInt zoom)

flatten2D : List (List a) -> List a
flatten2D list =
  List.foldr (++) [] list

mapLayer map createMapBoxUrl currentAnimationZoom currentAnimationLeftX currentAnimationTopY 
  currentAnimationViewBoxLeftX
  currentAnimationViewBoxTopY
  currentAnimationViewBoxWidth
  currentAnimationViewBoxHeight
  
  = 
  let
    zoomFactor = 2 ^ ((toFloat maxZoomLevel) - currentAnimationZoom)
    zoomFactorNoAnimation = 2 ^ (( maxZoomLevel) - (map.zoom))
    -- zoomFactor = 2 ^ (maxZoomLevel - (map.zoom))
  in
    div 
      (ElmStyle.createStyleList 
            [ ("position", "absolute")
            , ("pointer-events", "none")])
       [
         keyedSvg 
          [
            Svg.Attributes.viewBox 
              -- ( 
              --   ( String.fromInt ( map.finalPixelCoordinateWindow.leftX  * zoomFactorNoAnimation) ) ++ " " ++
              --   ( String.fromInt ( map.finalPixelCoordinateWindow.topY * zoomFactorNoAnimation) )  ++ " " ++
              --   ( String.fromInt ( map.window.width * zoomFactorNoAnimation  ))  ++ " " ++
              --   ( String.fromInt ( map.window.height * zoomFactorNoAnimation ))
              -- )
              ( 
                ( String.fromFloat (currentAnimationViewBoxLeftX / 256) ) ++ " " ++
                ( String.fromFloat (currentAnimationViewBoxTopY/ 256) )  ++ " " ++
                ( String.fromFloat (currentAnimationViewBoxWidth/ 256))  ++ " " ++
                ( String.fromFloat (currentAnimationViewBoxHeight/ 256))
              )
          , Svg.Attributes.width (String.fromInt map.window.width)
          , Svg.Attributes.height (String.fromInt map.window.height)
          ]
          (List.map 
            (\zoomLevel -> mapLayerZoom map createMapBoxUrl zoomLevel )
            -- [-3, -2,-1,0,1]
            [0]
          )
       ]
      

mapLayerZoom map createTileUrl zoomMinus = 
  let
    mapZoomed = ZoomLevel.newMapForMinusZoom map zoomMinus
    zoomFactor = 2 ^ (maxZoomLevel - (map.zoom + zoomMinus))
  in
    ( (String.fromInt (map.zoom + zoomMinus) ) -- KEY FOR ZOOM LAYER
    , Svg.g 
        []
        [ mapLayerTiles mapZoomed map createTileUrl zoomFactor ])

mapLayerTiles map mapOriginal createTileUrl zoomFactor = 
    Svg.g 
      []
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
    Svg.image 
      [
        Svg.Attributes.xlinkHref url
      , Svg.Attributes.x (String.fromInt (zoomFactor * tilePixelSize  * ( x)))
      , Svg.Attributes.y (String.fromInt (zoomFactor * tilePixelSize * ( y)))
      , Svg.Attributes.width (String.fromInt (zoomFactor * tilePixelSize))
      , Svg.Attributes.height (String.fromInt (zoomFactor * tilePixelSize))
      ]
      []

