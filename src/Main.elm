module Main exposing (..)

-- core
import Html exposing (Html, div, text, input, img)
import Html.Attributes exposing (style, class,value, src, alt)
import Html.Events exposing (onInput)
import Browser exposing(element)

-- self made modules
import ElmStyle
import SelfMadeMath
import Time
import Clock

-- Authentication
import MapboxAuth


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
    --  <img alt='static Mapbox map of the San Francisco bay area' src='https://api.mapbox.com/styles/v1/mapbox/streets-v10/static/-122.337798,37.810550,9.67,0.00,0.00/1000x600@2x?access_token=pk.eyJ1IjoiZGVycnlyb3ZlciIsImEiOiJjanByMGpnMHIwcms5NDJwMnl3MWlrdGttIn0.VMPuIHsIOkOo7b2YQVSy6Q' >


    [ img
      [ alt "static Mapbox map of the San Francisco bay area"
      , src "https://api.mapbox.com/styles/v1/mapbox/streets-v10/static/-122.337798,37.810550,9.67,0.00,0.00/1000x600@2x?access_token=pk.eyJ1IjoiZGVycnlyb3ZlciIsImEiOiJjanByMGpnMHIwcms5NDJwMnl3MWlrdGttIn0.VMPuIHsIOkOo7b2YQVSy6Q"  
      ]
      []
    , input 
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