module Main exposing (..)

-- core
import Html exposing (Html, div, text, input, img)
import Html.Attributes exposing (style, class,value, src, alt)
import Html.Events exposing (onInput, onClick)
import Browser exposing(element)

-- self made modules
import ElmStyle
import Map exposing(..)



type alias Model = 
  { map: Map.Model }

type Msg 
  =  None
  | MapMsg Map.Msg

main = Browser.element
  { init = init
  , view = view
  , update = update
  , subscriptions = subscriptions
  }

init : () -> (Model, Cmd Msg)
init _ =
  let (map, mapCmd) = Map.init ()
  in
    (
      { map = map }
      , Cmd.batch [Cmd.map  MapMsg mapCmd]
    )


view : Model -> Html Msg
view model = 
  div 
    []
    [ 
      Html.map MapMsg (Map.view model.map)
    ]

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = 
  case msg of
    MapMsg mapMsg ->
      let (map, mapMsgNew) = Map.update mapMsg model.map 
      in ({model | map = map}, Cmd.map MapMsg mapMsgNew)
    None ->
      (model, Cmd.none)


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none