module WheelDecoder exposing(..)

import Html exposing (div, text)
import Html.Events
import Html.Events.Extra.Wheel as Wheel
import Json.Decode as Decode
import ZoomLevel

-- type Zoom = ZoomIn | ZoomOut
type alias ModelDecoded = {x: Float, y: Float, zoom: Float}
type alias Model = {x: Float, y: Float, zoom: ZoomLevel.Msg}
type Msg
  = WheelMsg Model

type alias WheelEventWithOffsetXY =
  { wheelEvent : Wheel.Event
  , offsetXY : ModelDecoded
  }

decodeWeelWithOffsetXY : Decode.Decoder WheelEventWithOffsetXY
decodeWeelWithOffsetXY =
  Decode.map2 WheelEventWithOffsetXY
    Wheel.eventDecoder
    offsetXYDecoder

offsetXYDecoder : Decode.Decoder ModelDecoded
offsetXYDecoder =
  Decode.map3 (\x y zoom -> {x=x,y=y,zoom=zoom})
    (Decode.field "offsetX" Decode.float)
    (Decode.field "offsetY" Decode.float)
    -- (Decode.Decoder ZoomIn)
    (Decode.field "deltaY" Decode.float)

getFromMsg: Msg -> Model
getFromMsg (WheelMsg record) = record

toWheelMsg: WheelEventWithOffsetXY -> Msg
toWheelMsg wheelEvent = 
  WheelMsg 
  { x= (wheelEvent.offsetXY.x)
  , y= (wheelEvent.offsetXY.y)
  , zoom = getZoomFromWheelEvent wheelEvent 
  }

getZoomFromWheelEvent: WheelEventWithOffsetXY -> ZoomLevel.Msg
getZoomFromWheelEvent wheelEvent = 
  let deltaY = wheelEvent.wheelEvent.deltaY
  in
    if deltaY > 0 then
      ZoomLevel.Minus
    else
      ZoomLevel.Plus

view = 
  div
    [ onWheelOffsetXY toWheelMsg ]
    [ (text "mousewheel here") ]


onWheelOffsetXY : (WheelEventWithOffsetXY -> msg) -> Html.Attribute msg
onWheelOffsetXY tag =
  let
    options message =
        { message = message
        , stopPropagation = True
        , preventDefault = True
        }
    decoder =
        decodeWeelWithOffsetXY
        |> Decode.map tag 
        |> Decode.map options
  in
    Html.Events.custom "wheel" decoder


mouseWheelListener: Html.Attribute Msg
mouseWheelListener = 
  onWheelOffsetXY toWheelMsg
  -- (onWheelOffsetXY (\wheelEvent -> WheelMsg (wheelEvent.offsetXY)))
  -- Mouse.onMove (eventToPosition >> MouseMove)
