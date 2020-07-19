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
import MapBoxUtils exposing (createMapBoxUrl,createWmsUrl)
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
  , currentAnimationTimeLeft: Float
  
  , currentAnimationViewBoxLeftX: Float
  , currentAnimationViewBoxTopY: Float
  , currentAnimationViewBoxWidth: Float
  , currentAnimationViewBoxHeight: Float
  
  , currentAnimationZoom: Float
  , currentAnimationLeftX: Float
  , currentAnimationTopY: Float
  }


init : () -> (Model, Cmd Msg)
init _ = 
  let 
    map = map2
    zoomFactor = ZoomLevel.getZoomFactor (toFloat map.zoom)
  in
    (
        { dragStart = 
          { x = 0
          , y = 0
          }
        , dragStartPixels = map.finalPixelCoordinateWindow
        , mouseDown = False
        , map = map
        , currentAnimationTimeLeft = 0.0

        , currentAnimationViewBoxLeftX = (toFloat map.finalPixelCoordinateWindow.leftX)  * zoomFactor
        , currentAnimationViewBoxTopY = (toFloat map.finalPixelCoordinateWindow.topY)  * zoomFactor
        , currentAnimationViewBoxWidth = (toFloat map.window.width)  * zoomFactor
        , currentAnimationViewBoxHeight = (toFloat map.window.height)  * zoomFactor

        , currentAnimationZoom = toFloat map.zoom
        , currentAnimationLeftX = toFloat map.finalPixelCoordinateWindow.leftX
        , currentAnimationTopY = toFloat map.finalPixelCoordinateWindow.topY
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

calculateAnimationValue timeFraction currentValue eventualValue = 
  let
    valueDelta = currentValue - eventualValue
    newValue = currentValue - (timeFraction * valueDelta)
  in
    if currentValue > eventualValue then
      if newValue < eventualValue then
        eventualValue
      else
        newValue
    else 
      if newValue > eventualValue then
        eventualValue
      else
        newValue

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = 
  case msg of
    TimeDelta delta ->
      let
          map = model.map
          
          tempAnimationTimeLeft = model.currentAnimationTimeLeft - delta
          timeFraction = delta / model.currentAnimationTimeLeft
          improvedTimeFraction = 
            if timeFraction > 1 then
              1
            else
              timeFraction
          zoomFactor = ZoomLevel.getZoomFactor (toFloat map.zoom)

          eventualZoom = toFloat model.map.zoom
          eventualLeftX = toFloat model.map.finalPixelCoordinateWindow.leftX
          eventualTopY = toFloat model.map.finalPixelCoordinateWindow.topY
          newZoom = calculateAnimationValue improvedTimeFraction model.currentAnimationZoom eventualZoom
          newLeftX = calculateAnimationValue improvedTimeFraction model.currentAnimationLeftX eventualLeftX
          newTopY = calculateAnimationValue improvedTimeFraction model.currentAnimationTopY eventualTopY
      in
      (
      { model 
        | currentAnimationTimeLeft = 
          if tempAnimationTimeLeft > 0 then
            tempAnimationTimeLeft
          else
            0

        , currentAnimationViewBoxLeftX = 
            calculateAnimationValue 
              improvedTimeFraction 
              model.currentAnimationViewBoxLeftX 
              ((toFloat map.finalPixelCoordinateWindow.leftX)  * zoomFactor)
        , currentAnimationViewBoxTopY = 
            calculateAnimationValue 
              improvedTimeFraction 
              model.currentAnimationViewBoxTopY 
              ((toFloat map.finalPixelCoordinateWindow.topY)  * zoomFactor)
        , currentAnimationViewBoxWidth = 
            calculateAnimationValue 
              improvedTimeFraction 
              model.currentAnimationViewBoxWidth 
              ((toFloat map.window.width)  * zoomFactor)
        , currentAnimationViewBoxHeight = 
            calculateAnimationValue 
              improvedTimeFraction 
              model.currentAnimationViewBoxHeight  
              ((toFloat map.window.height)  * zoomFactor)

        , currentAnimationZoom = newZoom
        , currentAnimationLeftX = newLeftX
        , currentAnimationTopY = newTopY
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
        zoomFactor = ZoomLevel.getZoomFactor (toFloat map.zoom)
      in
      
      ( {model 
        | map = newMap
        , currentAnimationTimeLeft = 400 --miliseconds ?

        -- , currentAnimationViewBoxLeftX = (toFloat map.finalPixelCoordinateWindow.leftX)  * zoomFactor
        -- , currentAnimationViewBoxTopY = (toFloat map.finalPixelCoordinateWindow.topY)  * zoomFactor
        -- , currentAnimationViewBoxWidth = (toFloat map.window.width)  * zoomFactor
        -- , currentAnimationViewBoxHeight = (toFloat map.window.height)  * zoomFactor

        , currentAnimationZoom = toFloat model.map.zoom
        , currentAnimationLeftX = toFloat model.map.finalPixelCoordinateWindow.leftX
        , currentAnimationTopY = toFloat model.map.finalPixelCoordinateWindow.topY
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
            zoomFactor = ZoomLevel.getZoomFactor (toFloat newMap.zoom)
          in
          ({ model 
              | map = newMap
              , currentAnimationViewBoxLeftX = (toFloat newMap.finalPixelCoordinateWindow.leftX)  * zoomFactor
              , currentAnimationViewBoxTopY = (toFloat newMap.finalPixelCoordinateWindow.topY)  * zoomFactor
              , currentAnimationViewBoxWidth = (toFloat newMap.window.width)  * zoomFactor
              , currentAnimationViewBoxHeight = (toFloat newMap.window.height)  * zoomFactor
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
          , Pointer.onLeave
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
         MapLayer.mapLayer 
            model.map 
            createMapBoxUrl 
            
            model.currentAnimationZoom 
            model.currentAnimationLeftX 
            model.currentAnimationTopY
            
            model.currentAnimationViewBoxLeftX
            model.currentAnimationViewBoxTopY
            model.currentAnimationViewBoxWidth
            model.currentAnimationViewBoxHeight
      , MapLayer.mapLayer 
            model.map 
            createWmsUrl 
            
            model.currentAnimationZoom 
            model.currentAnimationLeftX 
            model.currentAnimationTopY
            
            model.currentAnimationViewBoxLeftX
            model.currentAnimationViewBoxTopY
            model.currentAnimationViewBoxWidth
            model.currentAnimationViewBoxHeight
      ]
    ]



