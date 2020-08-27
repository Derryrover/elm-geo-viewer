module MapLayer exposing(..)

import Html.Attributes exposing (style, class,value, src, alt, id)
import Html exposing (..)
import Html.Keyed
import Html.Events
import List

import ElmStyle
import Types
import ZoomLevel

import Svg
import Svg.Attributes
import Svg.Keyed
import Svg.Events
import MapVariables exposing (
  maxZoomLevel
  -- , tilePixelSize
  )
import Dict exposing (Dict)
import Json.Decode

type Msg 
  = 
  -- x y z
  TileLoaded Int Int Int

type alias Model = 
  { loadedTiles: Dict String Bool --List Int
  , a: Int
  }

init : () -> (Model, Cmd Msg)
init _ = 
  let 
    map = 1
    zoomFactor = 1
  in
    (
        { loadedTiles = Dict.fromList []
        , a = 0
        }
      , Cmd.batch []
    )


keyFromXYZ x y z = (String.fromInt x) ++ "-" ++ (String.fromInt y) ++ "-" ++ (String.fromInt z)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = 
  case msg of
    TileLoaded x y z -> 
      let
          key = keyFromXYZ x y z
      in
      
      (
        { loadedTiles = Dict.insert key True model.loadedTiles --[]
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

mapLayer model map createMapBoxUrl currentAnimationZoom currentAnimationLeftX currentAnimationTopY 
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
            (\zoomLevel -> mapLayerZoom model map createMapBoxUrl zoomLevel )
            -- [-3, -2,-1,0,1]
            [0]
          )
       ]
      

mapLayerZoom model map createTileUrl zoomMinus = 
  let
    mapZoomed = ZoomLevel.newMapForMinusZoom map zoomMinus
    zoomFactor = 2 ^ (maxZoomLevel - (map.zoom + zoomMinus))
  in
    ( (String.fromInt (map.zoom + zoomMinus) ) -- KEY FOR ZOOM LAYER
    , Svg.g 
        []
        [ mapLayerTiles model mapZoomed map createTileUrl zoomFactor ])

mapLayerTiles model map mapOriginal createTileUrl zoomFactor = 
    Svg.g 
      []
      [keyedSvgG [] 
           (flatten2D 
            ( List.map (\y ->
                List.map (\x ->
                  ( createKey x y map.zoom 
                  , imageDiv model map createTileUrl zoomFactor x y 
                  )) 
                  map.tileRange.rangeX
                )
              map.tileRange.rangeY
            ))
      ]

imageDiv model map createTileUrl zoomFactor x y = 
  let
    maxTilesOnAxis = Types.tilesFromZoom map.zoom
    xMod = modBy maxTilesOnAxis x
    yMod = modBy maxTilesOnAxis y
    url = createTileUrl map.zoom xMod yMod
    tileLoadedObj = Dict.get (keyFromXYZ x y map.zoom)  model.loadedTiles
    tileLoaded = 
      case tileLoadedObj of
         Nothing -> False
         Just bool -> bool
    attributes = [
        Svg.Attributes.xlinkHref url
      , Svg.Attributes.x (String.fromInt (zoomFactor * tilePixelSize  * ( x)))
      , Svg.Attributes.y (String.fromInt (zoomFactor * tilePixelSize * ( y)))
      , Svg.Attributes.width (String.fromInt (zoomFactor * tilePixelSize))
      , Svg.Attributes.height (String.fromInt (zoomFactor * tilePixelSize))
      ]
    attributesPlusOnload =
      if tileLoaded then attributes
      else List.concat [attributes, [Svg.Events.on "load" (Json.Decode.succeed (TileLoaded xMod yMod map.zoom))] ]
  in
    Svg.image 
      attributesPlusOnload
      []

