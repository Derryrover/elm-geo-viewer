module Main exposing (..)

-- core
import Html exposing (Html, div, text, input)
import Html.Attributes exposing (style, class,value)
import Html.Events exposing (onInput)
import Browser exposing(element)

-- self made modules
import ElmStyle
import SelfMadeMath
import Time
import Clock


type alias Model = 
  Time.Model

type Msg 
  = Hour Int
  | Minute Int
  | None

main = Browser.element
  { init = init
  , view = view
  , update = update
  , subscriptions = subscriptions
  }

init : () -> (Model, Cmd Msg)
init _ =
    (
       Time.Model 11 39
      --, Cmd.batch [Cmd.map SvgElementMsg svgElementMsg]
      , Cmd.batch []
    )

toIntMsg: (Int -> Msg) -> String -> Msg
toIntMsg msg str =
  case String.toInt str of
    Nothing -> 
      case str of
        "" -> msg 0
        _  -> None
    Just val -> msg val

view : Model -> Html Msg
view model = 
  div 
    []
    [ input 
      [ value (String.fromInt model.hours)
      , onInput (toIntMsg Hour)
      ] 
      []
    , input 
      [ value (String.fromInt model.minutes)
      , onInput (toIntMsg Minute)
      ] 
      []
    , (Clock.view model)
    ]

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = 
  case msg of
    Hour hr ->
      ({ model | hours = hr }, Cmd.none)
    Minute mn ->
      ({ model | minutes = mn }, Cmd.none)
    None ->
      (model, Cmd.none)
    -- ClockMsg Clock.Msg ->
    --   (model, Cmd.none)


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none