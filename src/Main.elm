module Main exposing (..)

-- core
import Html exposing (Html, div, text, input, img)
import Html.Attributes exposing (style, class,value, src, alt)
import Html.Events exposing (onInput, onClick)
import Browser exposing(element)

-- self made modules
import ElmStyle
import SelfMadeMath
import Time
import Clock
import Map exposing(..)

-- Authentication
import MapboxAuth


type alias Model = 
  { time: Time.Model
  , map: Map.Model }

type Msg 
  = Hour Int
  | Minute Int
  | None
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
       { time = Time.Model 11 39
       , map = map }
      --, Cmd.batch [Cmd.map SvgElementMsg svgElementMsg]
      , Cmd.batch [Cmd.map  MapMsg mapCmd]
    )

toIntMsg: (Int -> Msg) -> String -> Msg
toIntMsg msg str =
  case String.toInt str of
    Nothing -> 
      case str of
        "" -> msg 0
        _  -> None
    Just val -> msg val

mapBoxApiBaseUrl = "https://api.mapbox.com/styles/v1/mapbox/streets-v10/static/"
boundingBox = "-122.337798,37.810550,9.67,0.00,0.00/1000x600@2x"
accesToken = "?access_token=" ++ MapboxAuth.key
mapBoxUrl = mapBoxApiBaseUrl ++ boundingBox ++ accesToken


view : Model -> Html Msg
view model = 
  div 
    []


    [ 
      Html.map MapMsg (Map.view model.map)
      -- img
      -- [ alt "static Mapbox map of the San Francisco bay area"
      -- , src mapBoxUrl
      -- ]
      -- []
    -- , input 
    --   [ value (String.fromInt model.time.hours)
    --   , onInput (toIntMsg Hour)
    --   ] 
    --   []
    -- , input 
    --   [ value (String.fromInt model.time.minutes)
    --   , onInput (toIntMsg Minute)
    --   ] 
    --   []
    -- , (Clock.view model.time)
    ]

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = 
  case msg of
    MapMsg mapMsg ->
      let (map, mapMsg2) = Map.update mapMsg model.map 
      in ({model | map = map}, Cmd.map MapMsg mapMsg2)
    Hour hr ->
      let 
        time = model.time
        newTime = {time | hours = hr}
      in ({model | time = newTime}, Cmd.none)
    Minute mn ->
      let 
        time = model.time
        newTime = {time | minutes = mn}
      in ({model | time = newTime}, Cmd.none)
    None ->
      (model, Cmd.none)
    -- ClockMsg Clock.Msg ->
    --   (model, Cmd.none)


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none