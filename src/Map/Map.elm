module Map exposing(..)

--import Html exposing (Html, div, text, input, img)
import Html.Attributes exposing (style, class,value, src, alt)
import Html.Events exposing (onInput, onClick)
import Browser exposing(element)
-- import MouseEvents exposing (onMouseMove)
import Html exposing (..)
import Html.Events
import Html.Events.Extra.Pointer as Pointer

-- self made modules
import ElmStyle
import List

-- Authentication
import MapboxAuth

type alias Model = 
  { x: Float,
    y: Float
  }

type Msg 
  = Click Float Float
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
       Model 0 0
      , Cmd.batch []
    )

-- mapBoxApiBaseUrl = "https://api.mapbox.com/styles/v1/mapbox/streets-v10/static/"
-- boundingBox = "-122.337798,37.810550,9.67,0.00,0.00/1000x600@2x"
-- accesToken = "?access_token=" ++ MapboxAuth.key
-- -- mapBoxUrl = mapBoxApiBaseUrl ++ boundingBox ++ accesToken
-- mapBoxUrl = "http://tile.stamen.com/terrain-background/4/2/2.png"
-- mapBoxUrl2 = "http://tile.stamen.com/terrain-background/4/3/2.png"

createMapBoxUrl zoomInt xInt yInt = 
  let
    x = String.fromInt xInt
    y = String.fromInt yInt
    zoom = String.fromInt zoomInt
  in
    "http://tile.stamen.com/terrain-background/"++zoom++"/"++x++"/"++y++".png"
  



getX event = 
  let (x,y) = event.pointer.offsetPos
  in x

getY event = 
  let (x,y) = event.pointer.offsetPos
  in y

view : Model -> Html Msg
view model = 
  div 
    []
    [ 
      text "x"
    , text (String.fromFloat model.x )
    , text "y"
    , text (String.fromFloat model.y )
    , div
      []
      (
        List.map
        (
          \y ->
          div
            []
            (List.map 
              (
                \x ->
                img
                [ src (createMapBoxUrl 4 x y)
                , Pointer.onDown (\event -> Click (getX event) (getY event))
                ]
                []
              ) 
              (List.range 1 5)
            )
        )
        (List.range 1 5)
      )
      -- [ div
      --   []
      --   (List.map 
      --     (
      --       \x ->
      --       img
      --       [ src (createMapBoxUrl 4 x y)
      --       , Pointer.onDown (\event -> Click (getX event) (getY event))
      --       ]
      --       []
      --     ) 
      --     (List.range 1 5)
      --   )
      -- ]
      
    ]

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = 
  case msg of
    Click x y ->
      ({ model | x = x, y = y }, Cmd.none)
    None ->
      (model, Cmd.none)


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

