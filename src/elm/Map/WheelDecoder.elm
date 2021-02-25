module WheelDecoder exposing(getFromMsg, mouseWheelListener, Msg)

import Html 
import Html.Events
import Html.Events.Extra.Wheel as Wheel
import Json.Decode as Decode
import ZoomLevel


mouseWheelListener: Html.Attribute Msg
mouseWheelListener = 
  Html.Events.custom 
    "wheel" 
    decoder

decoder = 
  Decode.map 
    options
    (
      Decode.map 
        toWheelMsg
        decodeWeelWithOffsetXY
    )
    
options message =
  { message = message
  , stopPropagation = True
  , preventDefault = True
  }

type alias Model = 
  { x: Float
  , y: Float
  , zoom: ZoomLevel.Msg
  }
type Msg
  = WheelMsg Model

getFromMsg: Msg -> Model
getFromMsg (WheelMsg record) = record

decodeWeelWithOffsetXY : Decode.Decoder WheelEventWithOffsetXY
decodeWeelWithOffsetXY =
  Decode.map2 WheelEventWithOffsetXY
    Wheel.eventDecoder
    offsetXYDecoder

type alias WheelEventWithOffsetXY =
  { wheelEvent : Wheel.Event
  , offsetXY : ModelDecoded
  }

type alias ModelDecoded = {x: Float, y: Float}

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
