module Map exposing(..)

import Html.Attributes exposing (style, class,value, src, alt, id)
import Html.Events exposing (onInput, onClick)
import Browser exposing(element)
import Html exposing (..)
import Html.Keyed exposing(node)
import Html.Events
import Html.Events.Extra.Pointer as Pointer
-- self made modules
import ElmStyle
-- import SizeXYLongLat exposing(getTileRange)
import List
-- import ProjectionWebMercator exposing(..)
import Types exposing(..)
import CoordinateUtils exposing(Coordinate2d(..), PixelPoint)
import CoordinateViewer
import MapBoxUtils exposing (createMapBoxUrl)
import ZoomLevel

import Json.Decode as Decode
import MousePosition

import WheelDecoder
-- import MouseCustomEvent

-- self made data
import MapData exposing ( map1, map2 )
-- Authentication
--import MapboxAuth

keyedDiv = node "div"

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
  , dragStartPixels: PixelCoordinateWindow
  , dragPrevious: PixelPoint
  , mouseDown: Bool
  , map: CompleteMapConfiguration
  , mousePosition: MousePosition.Model
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
        , dragStartPixels = map2.finalPixelCoordinateWindow
        , mouseDown = False
        , map = map2
        , mousePosition = MousePosition.init
        }
      , Cmd.batch []
    )

type Msg 
  = Click (Float, Float)
  | MouseDown (Float, Float)
  | MouseMove (Float, Float)
  | MouseUp (Float, Float)
  | ZoomLevelMsg ZoomLevel.Msg
  | MousePositionMsg MousePosition.Msg
  | WheelDecoderMsg WheelDecoder.Msg
  | None


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = 
  case msg of
    WheelDecoderMsg wheelDecoderMsg ->
      --  ({model | mousePosition = WheelDecoder.getFromMsg wheelDecoderMsg}, Cmd.none)
      let
        mousePosition = 
          { x = (WheelDecoder.getFromMsg wheelDecoderMsg).x
          , y = (WheelDecoder.getFromMsg wheelDecoderMsg).y
          }
        plusOrMinus = (WheelDecoder.getFromMsg wheelDecoderMsg).zoom
        map = model.map
        zoom = map.zoom
        newZoom = ZoomLevel.update plusOrMinus zoom
        -- mapCenter = { x =  map.window.width // 2, y = map.window.height // 2}
        mapCenter = {x=round mousePosition.x, y= round  mousePosition.y}
        newMap = ZoomLevel.updateWholeMapForZoom newZoom mapCenter map
      in
      
      ( {model 
        | mousePosition = mousePosition
        , map = newMap
        }
      , Cmd.none
      )
    MousePositionMsg mousePositionMsg ->
      -- ({model | mousePosition = MousePosition.update mousePositionMsg model.mousePosition}, Cmd.none)
      (model, Cmd.none)
    ZoomLevelMsg plusOrMinus ->
      let 
        map = model.map
        zoom = map.zoom
        newZoom = ZoomLevel.update plusOrMinus zoom
        mapCenter = { x =  map.window.width // 2, y = map.window.height // 2}
        newMap = ZoomLevel.updateWholeMapForZoom newZoom mapCenter map
      in
        ({model | map = newMap}, Cmd.none)
    Click (x, y) ->
      ({ model | x = x, y = y }, Cmd.none)
    MouseDown (x, y) ->
      ({ model 
          | mouseDown = True
          , dragStart = {x = x, y = y}
          , dragPrevious = {x = x, y = y}
          , dragStartPixels = model.map.finalPixelCoordinateWindow
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
            newPixelCoordinateWindow = panPixelCoordinateWindow model.dragStartPixels model.map.window deltaX deltaY model.map.zoom
            newGeoCoordinateWindow = transformPixelToGeoCoordinateWindow model.map.zoom newPixelCoordinateWindow
            newTileRange = Types.getTileRange newPixelCoordinateWindow
            newMap = { tempMap 
                        | finalPixelCoordinateWindow = newPixelCoordinateWindow
                        , finalGeoCoordinateWindow = newGeoCoordinateWindow
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
  let
    maxTilesOnAxis = Types.tilesFromZoom model.map.zoom
  in
  
  div 
    []
    [ 
      --CoordinateViewer.view model.x model.y model.map.zoom    
     --CoordinateUtils.view model.dragPrevious model.map.tileRange.panFromLeft model.map.tileRange.panFromTop
      CoordinateUtils.view model.dragPrevious model.map.finalPixelCoordinateWindow.leftX model.map.finalPixelCoordinateWindow.topY
    , CoordinateUtils.view model.dragPrevious model.map.tileRange.panFromLeft model.map.tileRange.panFromTop
     
    , Html.map ZoomLevelMsg (ZoomLevel.view model.map.zoom)
    , MousePosition.view model.mousePosition
    , div
      ( 
         List.concat [
          [
            -- Pointer.onDown 
            --   (\event -> 
            --     let (x,y) = event.pointer.offsetPos 
            --     in Click ( x + toFloat model.map.finalPixelCoordinateWindow.leftX
            --              , y + toFloat model.map.finalPixelCoordinateWindow.topY
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
          , ( Html.Attributes.map MousePositionMsg MousePosition.mouseMoveListener)
          , ( Html.Attributes.map WheelDecoderMsg  WheelDecoder.mouseWheelListener)
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
        keyedDiv 
          (
           
            ElmStyle.createStyleList 
              [ ("position", "absolute")
              -- , ("top", (String.fromInt -model.map.tileRange.panFromTop)++"px")
              -- , ("left", (String.fromInt -model.map.tileRange.panFromLeft)++"px")
              , ("top", (String.fromInt -model.map.finalPixelCoordinateWindow.topY)++"px")
              , ("left", (String.fromInt -model.map.finalPixelCoordinateWindow.leftX)++"px")
              -- , ("transition", "top 0.02s, left 0.02s")
              , ("pointer-events", "none")
              ] 
          )
          -- (List.concat
          (
          List.map
          (
            \y ->
            (
              ("y_value_"++(String.fromInt y)) 
            ,keyedDiv
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
                  (
                    ("x_y_value_"++(String.fromInt x) ++ "_"++(String.fromInt y)) 
                  , div
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
                      [ src (createMapBoxUrl model.map.zoom (modBy maxTilesOnAxis x) (modBy maxTilesOnAxis y))
                      ]
                  ]
                  )
                  []
                  ]
                )) 
                model.map.tileRange.rangeX
              )
          ))
          model.map.tileRange.rangeY
        )
        -- )
      ]
    ]



