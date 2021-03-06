module ZoomLevel exposing (..)

import Html.Attributes exposing (style, class,value, src, alt, id)
import Html.Events exposing (onInput, onClick)
import Browser exposing(element)
import Html exposing (..)
import Html.Events
import Html.Events.Extra.Pointer as Pointer
import Types
import ProjectionWebMercator

type alias Model = Int

type Msg 
  = Plus
  | Minus

update : Msg -> Model -> Model
update msg model = 
  case msg of 
    Plus -> model + 1
    Minus -> model - 1

updateWholeMapForZoom : Model -> Types.PixelCoordinatePoint ->  Types.CompleteMapConfiguration -> Types.CompleteMapConfiguration
updateWholeMapForZoom  newZoom windowZoomCenter oldMapConfiguration = --oldMapConfiguration
  let
    pixelZoomCenter = --Types.getPixelCenterFromWindow oldMapConfiguration.finalPixelCoordinateWindow
      { x = oldMapConfiguration.finalPixelCoordinateWindow.leftX + windowZoomCenter.x
      , y = oldMapConfiguration.finalPixelCoordinateWindow.topY + windowZoomCenter.y
      }
    geoZoomCenter = Types.pixelPointToGeoPointCoordinates oldMapConfiguration.zoom pixelZoomCenter
    pixelCenterNewZoom = --Types.getPixelCenterFromWindow oldMapConfiguration.finalPixelCoordinateWindow
      { x = round (ProjectionWebMercator.longToX geoZoomCenter.long newZoom)
      , y = round (ProjectionWebMercator.latToY geoZoomCenter.lat newZoom)
      }
    newPixelWindowLeftX = pixelCenterNewZoom.x - windowZoomCenter.x
    newPixelWindowRightX = newPixelWindowLeftX + oldMapConfiguration.window.width
    newPixelWindowTopY = pixelCenterNewZoom.y - windowZoomCenter.y
    newPixelWindowBottomY = newPixelWindowTopY + oldMapConfiguration.window.height
    newPixelWindow = 
      { leftX = newPixelWindowLeftX
      , rightX = newPixelWindowRightX
      , topY = newPixelWindowTopY
      , bottomY = newPixelWindowBottomY
      }
    newGeoWindow = Types.transformPixelToGeoCoordinateWindow newZoom newPixelWindow
  in
    { oldMapConfiguration
    | zoom = newZoom
    , finalPixelCoordinateWindow = newPixelWindow
    , finalGeoCoordinateWindow = newGeoWindow
    , tileRange = Types.getTileRange newPixelWindow newZoom
    }

view : Model -> Html Msg
view model = 
  div 
    [] 
    [ button [ onClick Plus] [text "+"]
    , div [] [text (String.fromInt model)]
    -- , div [] [text (toString model)]
    , button [ onClick Minus] [text "-"]
    ] 

