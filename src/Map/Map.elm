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
import List
import Types 

import CoordinateUtils exposing(Coordinate2d(..), PixelPoint)
import MapBoxUtils exposing (createMapBoxUrl)
import ZoomLevel

import Json.Decode as Decode

import WheelDecoder

-- self made data
import MapData exposing ( map1, map2 )

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
  { dragStart: PixelPoint
  , dragStartPixels: Types.PixelCoordinateWindow
  , mouseDown: Bool
  , map: Types.CompleteMapConfiguration
  }

init : () -> (Model, Cmd Msg)
init _ = 
  let map = map2
  in
    (
        { dragStart = 
          { x = 0
          , y = 0
          }
        , dragStartPixels = map.finalPixelCoordinateWindow
        , mouseDown = False
        , map = map
        }
      , Cmd.batch []
    )

type Msg 
  = MouseDown (Float, Float)
  | MouseMove (Float, Float)
  | MouseUp (Float, Float)
  | ZoomLevelMsg ZoomLevel.Msg
  | WheelDecoderMsg WheelDecoder.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = 
  case msg of
    WheelDecoderMsg wheelDecoderMsg ->
      let
        mousePosition = 
          { x = (WheelDecoder.getFromMsg wheelDecoderMsg).x
          , y = (WheelDecoder.getFromMsg wheelDecoderMsg).y
          }
        plusOrMinus = (WheelDecoder.getFromMsg wheelDecoderMsg).zoom
        map = model.map
        zoom = map.zoom
        newZoom = ZoomLevel.update plusOrMinus zoom
        zoomCenter = {x=round mousePosition.x, y= round  mousePosition.y}
        newMap = ZoomLevel.updateWholeMapForZoom newZoom zoomCenter map
      in
      
      ( {model 
        | map = newMap
        }
      , Cmd.none
      )
    ZoomLevelMsg plusOrMinus ->
      let 
        map = model.map
        zoom = map.zoom
        newZoom = ZoomLevel.update plusOrMinus zoom
        mapCenter = { x =  map.window.width // 2, y = map.window.height // 2}
        newMap = ZoomLevel.updateWholeMapForZoom newZoom mapCenter map
      in
        ({model | map = newMap}, Cmd.none)
    MouseDown (x, y) ->
      ({ model 
          | mouseDown = True
          , dragStart = {x = x, y = y}
          , dragStartPixels = model.map.finalPixelCoordinateWindow
        }
        , Cmd.none
      )
    MouseMove (x, y) ->
      case model.mouseDown of
        False ->
          ( model , Cmd.none )
        True ->
          let 
            tempMap = model.map
            deltaX = x - model.dragStart.x
            deltaY = y - model.dragStart.y
            newPixelCoordinateWindow = Types.panPixelCoordinateWindow model.dragStartPixels model.map.window deltaX deltaY model.map.zoom
            newGeoCoordinateWindow = Types.transformPixelToGeoCoordinateWindow model.map.zoom newPixelCoordinateWindow
            newTileRange = Types.getTileRange newPixelCoordinateWindow
            newMap = { tempMap 
                        | finalPixelCoordinateWindow = newPixelCoordinateWindow
                        , finalGeoCoordinateWindow = newGeoCoordinateWindow
                        , tileRange = newTileRange tempMap.zoom
                        }
          in
          ({ model 
              | map = newMap
            }
            , Cmd.none
          )
    MouseUp (x, y) ->
      ({ model 
          | mouseDown = False
        }
        , Cmd.none
      )


view : Model -> Html Msg
view model = 
  let
    maxTilesOnAxis = Types.tilesFromZoom model.map.zoom
  in
  div 
    []
    [ 
      CoordinateUtils.view model.dragStart model.map.finalPixelCoordinateWindow.leftX model.map.finalPixelCoordinateWindow.topY
    , CoordinateUtils.view model.dragStart model.map.finalPixelCoordinateWindow.rightX model.map.finalPixelCoordinateWindow.bottomY
    --, Html.map ZoomLevelMsg (ZoomLevel.view model.map.zoom)
    , div
      ( List.concat [
          [ Pointer.onDown 
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
          , ( Html.Attributes.map WheelDecoderMsg  WheelDecoder.mouseWheelListener)
          ],(
        ElmStyle.createStyleList 
          [ ("height", ElmStyle.intToPxString model.map.window.height )
          , ("width", ElmStyle.intToPxString model.map.window.width )
          , ("overflow", "hidden")
          , ("position", "relative")
          ] 
          )])
      [ keyedDiv 
          (ElmStyle.createStyleList 
            [ ("position", "absolute")
            , ("top", ElmStyle.intToPxString -model.map.finalPixelCoordinateWindow.topY)
            , ("left", ElmStyle.intToPxString -model.map.finalPixelCoordinateWindow.leftX)
            , ("pointer-events", "none")
            ] 
          )
          ( List.map (\y ->
            ( ("keyed_div_y_value_"++(String.fromInt y)) 
            , keyedDiv
              ( ElmStyle.createStyleList 
                  [ ("height", ElmStyle.intToPxString Types.tilePixelSize)
                  , ("position", "absolute")
                  , ("top", ElmStyle.intToPxString (256 * y))
                  ] 
              )
              (List.map (\x ->
                ( ("keyed_div_x_y_value_"++(String.fromInt x) ++ "_"++(String.fromInt y)) 
                , div
                ( ElmStyle.createStyleList 
                          [ ("height", ElmStyle.intToPxString Types.tilePixelSize)
                          , ("width", ElmStyle.intToPxString Types.tilePixelSize)
                          , ("position", "absolute")
                          , ("left", ElmStyle.intToPxString (256 * x)) ])
                [ img
                  (List.concat [ 
                    [ (src (createMapBoxUrl model.map.zoom (modBy maxTilesOnAxis x) (modBy maxTilesOnAxis y)))]
                  , ( ElmStyle.createStyleList 
                      [ ("height", "100%")
                      , ("width", "100%") ]
                    )])
                  [] ]
                )) 
                model.map.tileRange.rangeX
              )
          ))
          model.map.tileRange.rangeY
        )
      ]
    ]



