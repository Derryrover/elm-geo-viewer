module WheelDecoder exposing(..)

import Html.Attributes exposing (style, class,value, src, alt, id)
import Html.Events exposing (onInput, onClick)
import Browser exposing(element)
import Html exposing (..)

import Html.Events
import Html.Events.Extra.Pointer as Pointer
import Html.Events.Extra.Wheel as Wheel

import Json.Decode as Decode


type alias EventWithOffsetPos =
    { wheelEvent : Wheel.Event
    , offsetPos : {x: Float, y: Float}
    }

decodeWithOffsetPos : Decode.Decoder EventWithOffsetPos
decodeWithOffsetPos =
    Decode.map2 EventWithOffsetPos
        Wheel.eventDecoder
        offsetPosDecoder

offsetPosDecoder : Decode.Decoder {x: Float, y: Float}
offsetPosDecoder =
    Decode.map2 (,)
        (Decode.field "offsetY" Decode.float)
        (Decode.field "offsetY" Decode.float)

type Msg
    = Wheeli {x: Float, y: Float}

div
    [ onWheeli (.offsetPos >> Wheeli) ]
    [ text "move here" ]


onWheeli : (EventWithOffsetPos -> msg) -> Html.Attribute msg
onWheeli tag =
    let
        options =
            { stopPropagation = True, preventDefault = True }
    in
    Decode.map tag decodeWithOffsetPos
        |> Html.Events.onWithOptions "mousemove" options

--------------------------------------------------------------------------

type alias EventWithMovement =
    { mouseEvent : Mouse.Event
    , movement : ( Float, Float )
    }

decodeWithMovement : Decoder EventWithMovement
decodeWithMovement =
    Decode.map2 EventWithMovement
        Wheel.eventDecoder
        movementDecoder

movementDecoder : Decoder ( Float, Float )
movementDecoder =
    Decode.map2 (,)
        (Decode.field "movementX" Decode.float)
        (Decode.field "movementY" Decode.float)

type Msg
    = Movement ( Float, Float )

div
    [ onMove (.movement >> Movement) ]
    [ text "move here" ]


onMove : (EventWithMovement -> msg) -> Html.Attribute msg
onMove tag =
    let
        options =
            { stopPropagation = True, preventDefault = True }
    in
    Decode.map tag decodeWithMovement
        |> Html.Events.onWithOptions "mousemove" options