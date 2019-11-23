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
import MapLayer
import MapLayerDeeperZoom

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
    map = model.map
  in
  div 
    []
    [ 
      CoordinateUtils.view model.dragStart map.window.width map.finalPixelCoordinateWindow.rightX
    -- , CoordinateUtils.view model.dragStart map.finalPixelCoordinateWindow.rightX map.finalPixelCoordinateWindow.bottomY
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
          [ ("height", ElmStyle.intToPxString map.window.height )
          , ("width", ElmStyle.intToPxString map.window.width )
          , ("overflow", "hidden")
          , ("position", "relative")
          ] 
          )])
      [ 
        MapLayerDeeperZoom.mapLayer 
          (ZoomLevel.updateWholeMapForZoom 
            (map.zoom - 3)  
            { x = map.window.width // 16
            , y = map.window.height // 16}
            { map | 
              window =  {
                width = model.map.window.width // 8
              , height = model.map.window.height // 8  
              }
              , finalPixelCoordinateWindow = 
                let 
                  halfW = map.window.width // 16
                  halfH = map.window.height // 16
                  centerHorizontal = (map.finalPixelCoordinateWindow.leftX + map.finalPixelCoordinateWindow.rightX) // 2
                  centerVertical = (map.finalPixelCoordinateWindow.topY + map.finalPixelCoordinateWindow.bottomY) // 2
                in
                {
                  --   leftX = map.finalPixelCoordinateWindow.leftX + model.map.window.width // 4
                  -- , rightX = map.finalPixelCoordinateWindow.rightX - model.map.window.width // 4
                  -- , topY = map.finalPixelCoordinateWindow.topY + model.map.window.height // 4
                  -- , bottomY = map.finalPixelCoordinateWindow.bottomY - model.map.window.height // 4
                    leftX = centerHorizontal - halfW
                  , rightX = centerHorizontal + halfW
                  , topY = centerVertical - halfH
                  , bottomY = centerVertical + halfH
                } }) 
            createMapBoxUrl
            8
        ,
        MapLayerDeeperZoom.mapLayer 
          (ZoomLevel.updateWholeMapForZoom 
            (map.zoom - 2)  
            { x = map.window.width // 8
            , y = map.window.height // 8}
            { map | 
              window =  {
                width = model.map.window.width // 4
              , height = model.map.window.height // 4  
              }
              , finalPixelCoordinateWindow = 
                let 
                  halfW = map.window.width // 8
                  halfH = map.window.height // 8
                  centerHorizontal = (map.finalPixelCoordinateWindow.leftX + map.finalPixelCoordinateWindow.rightX) // 2
                  centerVertical = (map.finalPixelCoordinateWindow.topY + map.finalPixelCoordinateWindow.bottomY) // 2
                in
                {
                  --   leftX = map.finalPixelCoordinateWindow.leftX + model.map.window.width // 4
                  -- , rightX = map.finalPixelCoordinateWindow.rightX - model.map.window.width // 4
                  -- , topY = map.finalPixelCoordinateWindow.topY + model.map.window.height // 4
                  -- , bottomY = map.finalPixelCoordinateWindow.bottomY - model.map.window.height // 4
                    leftX = centerHorizontal - halfW
                  , rightX = centerHorizontal + halfW
                  , topY = centerVertical - halfH
                  , bottomY = centerVertical + halfH
                } }) 
            createMapBoxUrl
            4
        ,
        MapLayerDeeperZoom.mapLayer 
          (ZoomLevel.updateWholeMapForZoom 
            (map.zoom - 0)  
            { x = map.window.width // 2
            , y = map.window.height // 2}
            { map | 
              window =  {
                width = model.map.window.width // 1
              , height = model.map.window.height // 1 
              }
              , finalPixelCoordinateWindow = 
                let 
                  halfW = map.window.width // 2
                  halfH = map.window.height // 2
                  centerHorizontal = (map.finalPixelCoordinateWindow.leftX + map.finalPixelCoordinateWindow.rightX) // 2
                  centerVertical = (map.finalPixelCoordinateWindow.topY + map.finalPixelCoordinateWindow.bottomY) // 2
                in
                {
                  --   leftX = map.finalPixelCoordinateWindow.leftX + model.map.window.width // 4
                  -- , rightX = map.finalPixelCoordinateWindow.rightX - model.map.window.width // 4
                  -- , topY = map.finalPixelCoordinateWindow.topY + model.map.window.height // 4
                  -- , bottomY = map.finalPixelCoordinateWindow.bottomY - model.map.window.height // 4
                    leftX = centerHorizontal - halfW
                  , rightX = centerHorizontal + halfW
                  , topY = centerVertical - halfH
                  , bottomY = centerVertical + halfH
                } }) 
            createMapBoxUrl
            1
        ,  
        MapLayerDeeperZoom.mapLayer 
          (ZoomLevel.updateWholeMapForZoom 
            (map.zoom - 1)  
            { x = map.window.width // 4
            , y = map.window.height // 4}
            { map | 
              window =  {
                width = model.map.window.width // 2
              , height = model.map.window.height // 2  
              }
              , finalPixelCoordinateWindow = 
                let 
                  halfW = map.window.width // 4
                  halfH = map.window.height // 4
                  totalPixelHorizontal = (map.finalPixelCoordinateWindow.leftX + map.finalPixelCoordinateWindow.rightX) // 2
                  totalPixelVertical = (map.finalPixelCoordinateWindow.topY + map.finalPixelCoordinateWindow.bottomY) // 2
                in
                {
                  --   leftX = map.finalPixelCoordinateWindow.leftX + model.map.window.width // 4
                  -- , rightX = map.finalPixelCoordinateWindow.rightX - model.map.window.width // 4
                  -- , topY = map.finalPixelCoordinateWindow.topY + model.map.window.height // 4
                  -- , bottomY = map.finalPixelCoordinateWindow.bottomY - model.map.window.height // 4
                    leftX = totalPixelHorizontal - halfW
                  , rightX = totalPixelHorizontal + halfW
                  , topY = totalPixelVertical - halfH
                  , bottomY = totalPixelVertical + halfH
                } }) 
            createMapBoxUrl
            2
        --  , MapLayer.mapLayer model.map createMapBoxUrl
      ]
    ]



