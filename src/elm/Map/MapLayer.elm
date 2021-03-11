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
import GenericGeneratorWebcomponent
import Html
import EmitEvent
import HtmlEmpty


type Msg 
  = 
  -- x y z
  TileLoaded Int Int Int
  | AllTilesLoaded --Float
  | TileCoordinatesChanged Types.CompleteMapConfiguration

type alias Model = 
  { loadedTiles: Dict String Bool --List Int
  , triggerAllLoaded: Bool
  , a: Int
  , emitEvent: Maybe Msg
  }

areAllDictLoaded: Model -> Bool
areAllDictLoaded model = 
  let
    values = Dict.values model.loadedTiles
  in
    (List.all (\item -> item==True) values) && (List.length values) /= 0


mapToDictStrings: Types.CompleteMapConfiguration -> List String
mapToDictStrings map = 
  flatten2D
  ( List.map 
      (\x-> List.map 
        (\y->
          keyFromXYZ x y map.zoom
        )
        map.tileRange.rangeY
      ) 
      map.tileRange.rangeX
  )


init : Types.CompleteMapConfiguration -> Model
init map = 
   { loadedTiles = Dict.fromList (List.map (\key-> (key, False)) (mapToDictStrings map)) --Dict.fromList []
    , a = 0
    , triggerAllLoaded = False
    , emitEvent = Nothing
    }


keyFromXYZ x y z = (String.fromInt x) ++ "-" ++ (String.fromInt y) ++ "-" ++ (String.fromInt z)

update : Msg -> Model -> Model
update msg model = 
  case msg of
    TileCoordinatesChanged map ->
        { model | loadedTiles = Dict.fromList (List.map (\key-> (key, False)) (mapToDictStrings map))
        }
    TileLoaded x y z -> 
      let
          key = keyFromXYZ x y z
          newModel = { model | loadedTiles = Dict.insert key True model.loadedTiles 
                      }
          newModelLoaded = 
            if areAllDictLoaded newModel then 
              { newModel 
              | triggerAllLoaded = True
              , emitEvent = Just AllTilesLoaded
              }
            else 
              newModel

      in
        newModelLoaded
    AllTilesLoaded -> --_ ->
      { model 
      | triggerAllLoaded = False
      , emitEvent = Nothing
      }
tilePixelSize = 1 --256


keyedSvg = Svg.Keyed.node "svg"
keyedSvgG = Svg.Keyed.node "g"


createKey x y zoom = "keyed_str_x_y_"++(String.fromInt x) ++ "_"++(String.fromInt y) ++ "_" ++ (String.fromInt zoom)

flatten2D : List (List a) -> List a
flatten2D list =
  List.foldr (++) [] list

mapLayer model map createMapBoxUrl dateModel currentAnimationZoom currentAnimationLeftX currentAnimationTopY 
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
        --  GenericGeneratorWebcomponent.htmlNode 
        --     "always-fire-right-away"
        --     [ GenericGeneratorWebcomponent.onCreated Json.Decode.float AllTilesLoaded
        --     , Html.Attributes.attribute 
        --       "requestState" 
        --       (GenericGeneratorWebcomponent.requestStateToString 
        --         (if model.triggerAllLoaded then GenericGeneratorWebcomponent.Requested else GenericGeneratorWebcomponent.Idle)
        --       ) 
        --     ]
        --     [],
          -- if model.triggerAllLoaded then EmitEvent.emitEvent AllTilesLoaded
          -- else HtmlEmpty.htmlEmpty
        case model.emitEvent of
           Nothing ->
            HtmlEmpty.htmlEmpty
           Just msg ->
            EmitEvent.emitEvent msg

        , keyedSvg 
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
            (\zoomLevel -> mapLayerZoom model map createMapBoxUrl dateModel zoomLevel )
            -- [-3, -2,-1,0,1]
            [0]
          )
       ]
      

mapLayerZoom model map createTileUrl dateModel zoomMinus = 
  let
    mapZoomed = ZoomLevel.newMapForMinusZoom map zoomMinus
    zoomFactor = 2 ^ (maxZoomLevel - (map.zoom + zoomMinus))
  in
    ( (String.fromInt (map.zoom + zoomMinus) ) -- KEY FOR ZOOM LAYER
    , Svg.g 
        []
        [ mapLayerTiles model mapZoomed map createTileUrl dateModel zoomFactor ])

mapLayerTiles model map mapOriginal createTileUrl dateModel zoomFactor = 
    Svg.g 
      []
      [keyedSvgG [] 
           (flatten2D 
            ( List.map (\y ->
                List.map (\x ->
                  ( createKey x y map.zoom 
                  , imageDiv model map createTileUrl dateModel zoomFactor x y 
                  )) 
                  map.tileRange.rangeX
                )
              map.tileRange.rangeY
            ))
      ]

imageDiv model map createTileUrl dateModel zoomFactor x y = 
  let
    maxTilesOnAxis = Types.tilesFromZoom map.zoom
    xMod = modBy maxTilesOnAxis x
    yMod = modBy maxTilesOnAxis y
    url = createTileUrl map.zoom xMod yMod dateModel
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

