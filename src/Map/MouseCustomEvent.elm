module MouseCustomEvent exposing(..)

import Html exposing (div, text)
-- import Html.Events exposing (..)
import Html.Events.Extra.Mouse as Mouse
import Json.Decode as Decode


type alias EventWithMovement =
    { mouseEvent : Mouse.Event
    , movement : ( Float, Float )
    }

decodeWithMovement : Decode.Decoder EventWithMovement
decodeWithMovement =
    Decode.map2 EventWithMovement
        Mouse.eventDecoder
        movementDecoder

movementDecoder : Decode.Decoder ( Float, Float )
movementDecoder =
    Decode.map2 (\a b -> ( a, b ))
        (Decode.field "movementX" Decode.float)
        (Decode.field "movementY" Decode.float)

type Msg
    = Movement ( Float, Float )

view = 
  div
    [ (onMove (\event -> Movement (event.movement))) ]
    [ text "move here" ]


onMove : (EventWithMovement -> msg) -> Html.Attribute msg
onMove tag =
    let
        options =
            { stopPropagation = True, preventDefault = True }
    in
    Decode.map tag decodeWithMovement
        |> Mouse.onWithOptions "mousemove" options

