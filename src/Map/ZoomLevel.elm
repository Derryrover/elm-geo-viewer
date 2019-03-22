module ZoomLevel exposing (..)

import Html.Attributes exposing (style, class,value, src, alt, id)
import Html.Events exposing (onInput, onClick)
import Browser exposing(element)
import Html exposing (..)
import Html.Events
import Html.Events.Extra.Pointer as Pointer

type alias Model = Int

type Msg 
  = Plus
  | Minus

update : Msg -> Model -> Model
update msg model = 
  case msg of 
    Plus -> model + 1
    Minus -> model - 1

view : Model -> Html Msg
view model = 
  div 
    [] 
    [ button [ onClick Plus] [text "+"]
    , div [] [text (String.fromInt model)]
    -- , div [] [text (toString model)]
    , button [ onClick Minus] [text "-"]
    ] 

