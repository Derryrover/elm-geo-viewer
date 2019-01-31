module Map exposing(..)

import Html.Attributes exposing (style, class,value, src, alt)
import Html.Events exposing (onInput, onClick)
import Browser exposing(element)
import Html exposing (..)
import Html.Events
import Html.Events.Extra.Pointer as Pointer

-- self made modules
import ElmStyle
import SizeXYLongLat exposing(getTileRange)
import List
import ProjectionWebMercator exposing(..)
import Types exposing(..)
import MapData exposing ( map1 )

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
  let
    long = (xToLong (round model.x) 2)
    lat = (yToLat (round model.y) 2)
    xCalc = longToX long 2
    yCalc = latToY lat 2
  in
  
  div 
    []
    [ 
      div 
        [] 
        [  text "x: "
        , text (String.fromFloat model.x )
        ]
    , div 
        []
        [ text "y: "
        , text (String.fromFloat model.y )
        ]
    , div 
        []
        [ text "long: "
        , text (String.fromFloat  ((long/pi)*180))
        ]  
    , div 
        []
        [ text "lat: "
        , text (String.fromFloat  ((lat/pi)*180))
        ] 
    , div 
        []
        [ text "x: "
        , text (String.fromFloat xCalc )
        ]
    , div 
        []
        [ text "y: "
        , text (String.fromFloat yCalc )
        ]     
    , div
      ( 
         List.concat [
          [
            Pointer.onDown (\event -> Click (getX event) (getY event))
          ],(
        ElmStyle.createStyleList 
          [ ("height", (String.fromInt (map1.finalPixelCoordinates.bottomY - map1.finalPixelCoordinates.topY)) ++ "px")
          , ("width", (String.fromInt (map1.finalPixelCoordinates.rightX - map1.finalPixelCoordinates.leftX))++"px")
          , ("overflow", "hidden")
          , ("position", "relative")
          ] 
          )]
      )
      [
        div 
          (
           
            ElmStyle.createStyleList 
              [ ("position", "absolute")
              , ("top", (String.fromInt -map1.tileRange.panFromTop)++"px")
              , ("left", (String.fromInt -map1.tileRange.panFromLeft)++"px")
              , ("overflow", "hidden")
              , ("pointer-events", "none")
              ] 
          )
        
          (
          List.map
          (
            \y ->
            div
              ( ElmStyle.createStyleList 
                  [ ("pointer-events", "none")
                  , ("height", "256px")
                  , ("width", (String.fromInt (256*(List.length map1.tileRange.rangeX)))++"px")
                  ] 
              )
              (List.map 
                (
                  \x ->
                  img
                  (
                    List.concat [
                      [ src (createMapBoxUrl map1.zoom x y)
                      ]
                      , ( ElmStyle.createStyleList [("pointer-events", "none"),("height", "256px"), ("width", "256px")] )
                    ]
                  )
                  []
                ) 
                map1.tileRange.rangeX
              )
          )
          map1.tileRange.rangeY
        )
      ]
    ]



