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
import CoordinateUtils exposing(Coordinate2d(..))
import CoordinateViewer
import MapBoxUtils exposing (createMapBoxUrl)
-- self made data
import MapData exposing ( map1 )
-- Authentication
import MapboxAuth

type alias Model = 
  { x: Float,
    y: Float
  }

type Msg 
  = Click (Float, Float)
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
    Click (x, y) ->
      ({ model | x = x, y = y }, Cmd.none)
    None ->
      (model, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

view : Model -> Html Msg
view model = 
  div 
    []
    [ CoordinateViewer.view model.x model.y map1.zoom    
    , div
      ( 
         List.concat [
          [
            Pointer.onDown 
              (\event -> 
                let (x,y) = event.pointer.offsetPos 
                in Click ( x + toFloat map1.finalPixelCoordinates.leftX
                         , y + toFloat map1.finalPixelCoordinates.topY
                         )
              )
          ],(
        ElmStyle.createStyleList 
          [ ("height", (String.fromInt map1.window.height) ++ "px")
          , ("width", (String.fromInt map1.window.width)++"px")
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



