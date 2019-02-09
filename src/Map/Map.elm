module Map exposing(..)

import Html.Attributes exposing (style, class,value, src, alt, id)
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
import CoordinateUtils exposing(Coordinate2d(..), PixelPoint)
import CoordinateViewer
import MapBoxUtils exposing (createMapBoxUrl)
-- self made data
import MapData exposing ( map1, map2 )
-- Authentication
import MapboxAuth

main = Browser.element
  { init = init
  , view = view
  , update = update
  , subscriptions = subscriptions
  }

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

type alias Model = 
  { x: Float
  , y: Float
  , dragStart: PixelPoint
  , dragStartPixels: PixelCoordinates
  , dragPrevious: PixelPoint
  , mouseDown: Bool
  , map: CompleteMapConfiguration
  }

init : () -> (Model, Cmd Msg)
init _ =
    (
        { x = 0
        , y = 0
        , dragStart = 
          { x = 0
          , y = 0
          }
        , dragPrevious = 
          { x = 0
          , y = 0
          }
        , dragStartPixels = map1.finalPixelCoordinates
        , mouseDown = False
        , map = map1
        }
      , Cmd.batch []
    )

type Msg 
  = Click (Float, Float)
  | MouseDown (Float, Float)
  | MouseMove (Float, Float)
  | MouseUp (Float, Float)
  | None


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = 
  case msg of
    Click (x, y) ->
      ({ model | x = x, y = y }, Cmd.none)
    MouseDown (x, y) ->
      ({ model 
          | mouseDown = True
          , dragStart = {x = x, y = y}
          , dragPrevious = {x = x, y = y}
          , dragStartPixels = model.map.finalPixelCoordinates
        }
        , Cmd.none
      )
    MouseMove (x, y) ->
      case model.mouseDown of
        False ->
          ( model 
              -- | dragPrevious = {x = x, y = y}
            -- }
            , Cmd.none
          )
        True ->
          let 
            tempMap = model.map
            deltaX = x - model.dragStart.x
            deltaY = y - model.dragStart.y
            newPixelCoordinates = panPixelCoordinates model.dragStartPixels deltaX deltaY model.map.zoom
            newGeoCoordinates = transformPixelToGeoCoordinates model.map.zoom newPixelCoordinates
            newTileRange = Types.getTileRange newPixelCoordinates
            newMap = { tempMap 
                        | finalPixelCoordinates = newPixelCoordinates
                        , finalGeoCoordinates = newGeoCoordinates
                        , tileRange = newTileRange tempMap.zoom
                        }
          in
          ({ model 
              | dragPrevious = {x = x, y = y}
              , map = newMap
            }
            , Cmd.none
          )
    MouseUp (x, y) ->
      ({ model 
          | mouseDown = False
        }
        , Cmd.none
      )
    None ->
      (model, Cmd.none)


view : Model -> Html Msg
view model = 
  div 
    []
    [ CoordinateViewer.view model.x model.y model.map.zoom    
    , CoordinateUtils.view model.dragPrevious model.map.tileRange.panFromLeft model.map.tileRange.panFromTop
    , div
      ( 
         List.concat [
          [
            -- Pointer.onDown 
            --   (\event -> 
            --     let (x,y) = event.pointer.offsetPos 
            --     in Click ( x + toFloat model.map.finalPixelCoordinates.leftX
            --              , y + toFloat model.map.finalPixelCoordinates.topY
            --              )
            --   )
           Pointer.onDown 
              (\event -> 
                let (x,y) = event.pointer.offsetPos 
                in MouseDown (x,y)
              )
          , Pointer.onUp 
              (\event -> 
                let (x,y) = event.pointer.offsetPos 
                in MouseUp  (x,y)
              )
          , Pointer.onMove 
              (\event -> 
                let (x,y) = event.pointer.offsetPos 
                in MouseMove  (x,y)
              )
          ],(
        ElmStyle.createStyleList 
          [ ("height", (String.fromInt model.map.window.height) ++ "px")
          , ("width", (String.fromInt model.map.window.width)++"px")
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
              -- , ("top", (String.fromInt -model.map.tileRange.panFromTop)++"px")
              -- , ("left", (String.fromInt -model.map.tileRange.panFromLeft)++"px")
              , ("top", (String.fromInt -model.map.finalPixelCoordinates.topY)++"px")
              , ("left", (String.fromInt -model.map.finalPixelCoordinates.leftX)++"px")
              -- , ("transition", "top 0.2s, left 0.2s")
              , ("pointer-events", "none")
              ] 
          )
          -- (List.concat
          (
          List.map
          (
            \y ->
            div
              ( ElmStyle.createStyleList 
                  [ ("height", "256px")
                  , ("position", "absolute")
                  , ("top", (String.fromInt (256 * y)++"px"))
                  -- , ("width", (String.fromInt (256*(List.length model.map.tileRange.rangeX)))++"px")
                  ] 
              )
              (List.map 
                (
                  \x ->
                  div
                  (
                    List.concat [
                      [ 
                        -- src (createMapBoxUrl model.map.zoom x y)
                        id ("id_backgroundimg_" ++ (String.fromInt x) ++ "_"++(String.fromInt y) )
                      ]
                      , 
                      ( ElmStyle.createStyleList 
                            [ ("height", "256px")
                            , ("width", "256px")
                            , ("position", "absolute")
                            -- , ("top", (String.fromInt (256 * y)++"px"))
                            , ("left", (String.fromInt (256 * x)++"px"))
                            ] )
                    ]
                  )
                  [
                    img
                  (
                    List.concat [
                      [ src (createMapBoxUrl model.map.zoom x y)
                      ]
                  ]
                  )
                  []
                  ]
                ) 
                model.map.tileRange.rangeX
              )
          )
          model.map.tileRange.rangeY
        )
        -- )
      ]
    ]



