module Map exposing(..)

import Html.Attributes exposing (style, class,value, src, alt, id)
import Html.Events exposing (onInput, onClick)
import Browser exposing(element)
import Html exposing (..)
import Html.Keyed
import Html.Events
import Html.Events.Extra.Pointer as Pointer
-- self made modules
import ElmStyle
import List
import Types 

import CoordinateUtils exposing(Coordinate2d(..), PixelPoint)
import MapBoxUtils exposing (createMapBoxUrl)
import ZoomLevel
import MapLayer

import Json.Decode as Decode

import WheelDecoder

-- self made data
import MapData exposing ( map1, map2 )

import Browser
import Browser.Events

keyedDiv = Html.Keyed.node "div"

main = Browser.element
  { init = init
  , view = view
  , update = update
  , subscriptions = subscriptions
  }

subscriptions : Model -> Sub Msg
subscriptions model =
  if model.currentAnimationTimeLeft /= 0 then
    Browser.Events.onAnimationFrameDelta TimeDelta
  else 
    Sub.none

type alias Model = 
  { dragStart: PixelPoint
  , dragStartPixels: Types.PixelCoordinateWindow
  , mouseDown: Bool
  , map: Types.CompleteMapConfiguration
  , currentAnimationZoom: Float
  , currentAnimationTimeLeft: Float
  }

init : () -> (Model, Cmd Msg)
init _ = 
  let map = map2
  in
    (
        { dragStart = 
          { x = 0
          , y = 0
          }
        , dragStartPixels = map.finalPixelCoordinateWindow
        , mouseDown = False
        , map = map
        , currentAnimationZoom = toFloat map.zoom
        , currentAnimationTimeLeft = 0.0
        }
      , Cmd.batch []
    )

type Msg 
  = 
    TimeDelta Float
  | MouseDown (Float, Float)
  | MouseMove (Float, Float)
  | MouseUp (Float, Float)
  | ZoomLevelMsg ZoomLevel.Msg
  | WheelDecoderMsg WheelDecoder.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = 
  case msg of
    TimeDelta delta ->
      let
          eventualZoom = toFloat model.map.zoom
          tempAnimationTimeLeft = model.currentAnimationTimeLeft - delta
          animationZoomDelta = model.currentAnimationZoom - eventualZoom
          timeFraction = delta / model.currentAnimationTimeLeft
          improvedTimeFraction = 
            if timeFraction > 1 then
              1
            else
              timeFraction

          newZoom = 
            model.currentAnimationZoom - (improvedTimeFraction * animationZoomDelta)
          improvedNewZoom = 
            if model.currentAnimationZoom > eventualZoom then
              if newZoom < eventualZoom then
                eventualZoom
              else
                newZoom
            else 
              if newZoom > eventualZoom then
                eventualZoom
              else
                newZoom
      in
      
      (
      { model 
        | currentAnimationTimeLeft = 
          if tempAnimationTimeLeft > 0 then
            tempAnimationTimeLeft
          else
            0
        , currentAnimationZoom = improvedNewZoom
      } , Cmd.none)
    WheelDecoderMsg wheelDecoderMsg ->
      let
        mousePosition = 
          { x = (WheelDecoder.getFromMsg wheelDecoderMsg).x
          , y = (WheelDecoder.getFromMsg wheelDecoderMsg).y
          }
        plusOrMinus = (WheelDecoder.getFromMsg wheelDecoderMsg).zoom
        map = model.map
        zoom = map.zoom
        newZoom = ZoomLevel.update plusOrMinus zoom
        zoomCenter = {x=round mousePosition.x, y= round  mousePosition.y}
        newMap = ZoomLevel.updateWholeMapForZoom newZoom zoomCenter map
      in
      
      ( {model 
        | map = newMap
        , currentAnimationTimeLeft = 1000 --miliseconds ?
        , currentAnimationZoom = toFloat model.map.zoom
        }
      , Cmd.none
      )
    ZoomLevelMsg plusOrMinus ->
      let 
        map = model.map
        zoom = map.zoom
        newZoom = ZoomLevel.update plusOrMinus zoom
        mapCenter = { x =  map.window.width // 2, y = map.window.height // 2}
        newMap = ZoomLevel.updateWholeMapForZoom newZoom mapCenter map
      in
        ({model | map = newMap}, Cmd.none)
    MouseDown (x, y) ->
      ({ model 
          | mouseDown = True
          , dragStart = {x = x, y = y}
          , dragStartPixels = model.map.finalPixelCoordinateWindow
        }
        , Cmd.none
      )
    MouseMove (x, y) ->
      case model.mouseDown of
        False ->
          ( model , Cmd.none )
        True ->
          let 
            tempMap = model.map
            deltaX = x - model.dragStart.x
            deltaY = y - model.dragStart.y
            newPixelCoordinateWindow = Types.panPixelCoordinateWindow model.dragStartPixels model.map.window deltaX deltaY model.map.zoom
            newGeoCoordinateWindow = Types.transformPixelToGeoCoordinateWindow model.map.zoom newPixelCoordinateWindow
            newTileRange = Types.getTileRange newPixelCoordinateWindow
            newMap = { tempMap 
                        | finalPixelCoordinateWindow = newPixelCoordinateWindow
                        , finalGeoCoordinateWindow = newGeoCoordinateWindow
                        , tileRange = newTileRange tempMap.zoom
                        }
          in
          ({ model 
              | map = newMap
            }
            , Cmd.none
          )
    MouseUp (x, y) ->
      ({ model 
          | mouseDown = False
        }
        , Cmd.none
      )


view : Model -> Html Msg
view model = 
  let
    maxTilesOnAxis = Types.tilesFromZoom model.map.zoom
    map = model.map
  in
  div 
    []
    [ 
      -- CoordinateUtils.view model.dragStart map.window.width map.finalPixelCoordinateWindow.rightX
      CoordinateUtils.view {x=model.currentAnimationTimeLeft, y=model.currentAnimationZoom} map.window.width map.finalPixelCoordinateWindow.rightX
    -- , CoordinateUtils.view model.dragStart map.finalPixelCoordinateWindow.rightX map.finalPixelCoordinateWindow.bottomY
    --, Html.map ZoomLevelMsg (ZoomLevel.view model.map.zoom)
    , div
      ( List.concat [
          [ Pointer.onDown 
              (\event -> 
                let (x,y) = event.pointer.offsetPos 
                in MouseDown (x,y)
              )
          , Pointer.onUp 
              (\event -> 
                let (x,y) = event.pointer.offsetPos 
                in MouseUp  (x,y)
              )
          , Pointer.onMove 
              (\event -> 
                let (x,y) = event.pointer.offsetPos 
                in MouseMove  (x,y)
              )
          , ( Html.Attributes.map WheelDecoderMsg  WheelDecoder.mouseWheelListener)
          ],(
        ElmStyle.createStyleList 
          [ ("height", ElmStyle.intToPxString map.window.height )
          , ("width", ElmStyle.intToPxString map.window.width )
          , ("overflow", "hidden")
          , ("position", "relative")
          ] 
          )])
      [ 
         MapLayer.mapLayer model.map createMapBoxUrl model.currentAnimationZoom
      ]
    ]



