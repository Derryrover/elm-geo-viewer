module WheelDecoder exposing(getFromMsg, mouseWheelListener, Msg)

import Html exposing (div, text)
import Html.Events
import Html.Events.Extra.Wheel as Wheel
import Json.Decode as Decode
import ZoomLevel

type alias ModelDecoded = {x: Float, y: Float}
type alias Model = {x: Float, y: Float, zoom: ZoomLevel.Msg}
type Msg
  = WheelMsg Model

type alias WheelEventWithOffsetXY =
  { wheelEvent : Wheel.Event
  , offsetXY : ModelDecoded
  }

getFromMsg: Msg -> Model
getFromMsg (WheelMsg record) = record

decodeWeelWithOffsetXY : Decode.Decoder WheelEventWithOffsetXY
decodeWeelWithOffsetXY =
  Decode.map2 WheelEventWithOffsetXY
    Wheel.eventDecoder
    offsetXYDecoder

offsetXYDecoder : Decode.Decoder ModelDecoded
offsetXYDecoder =
  Decode.map2 (\x y -> {x=x,y=y})
    (Decode.field "offsetX" Decode.float)
    (Decode.field "offsetY" Decode.float)

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
