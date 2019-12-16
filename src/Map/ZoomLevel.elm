module ZoomLevel exposing (..)

import Html.Attributes exposing (style, class,value, src, alt, id)
import Html.Events exposing (onInput, onClick)
import Browser exposing(element)
import Html exposing (..)
import Html.Events
import Html.Events.Extra.Pointer as Pointer
import Types
import ProjectionWebMercator
import MapVariables

type alias Model = Int

type Msg 
  = Plus
  | Minus

update : Msg -> Model -> Model
update msg model = 
  case msg of 
    Plus -> model + 1
    Minus -> model - 1

view : Model -> Html Msg
view model = 
  div 
    [] 
    [ button [ onClick Plus] [text "+"]
    , div [] [text (String.fromInt model)]
    , button [ onClick Minus] [text "-"]
    ] 

getZoomFactor currentZoom = 2 ^ ((toFloat MapVariables.maxZoomLevel) - currentZoom)

updateWholeMapForZoom : Model -> Types.PixelCoordinatePoint ->  Types.CompleteMapConfiguration -> Types.CompleteMapConfiguration
updateWholeMapForZoom  newZoom windowZoomCenter oldMapConfiguration = 
  let
    -- transform center of zoom: from pixel offsetxy on element -> to pixel offsetxy on all existing tiles for that zoom level
    pixelZoomCenter = 
      { x = oldMapConfiguration.finalPixelCoordinateWindow.leftX + windowZoomCenter.x
      , y = oldMapConfiguration.finalPixelCoordinateWindow.topY + windowZoomCenter.y
      }
    -- transform the center of zoom: from pixels -> to lat long
    geoZoomCenter = Types.pixelPointToGeoPointCoordinates oldMapConfiguration.zoom pixelZoomCenter
    -- transform the center of zoom: from lat long -> to pixel offsetxy for the new zoom level
    pixelCenterNewZoom = Types.geoPoinCoordinatesToPixelPoint newZoom geoZoomCenter
    -- calculate from the new pixel zoom center the borders of the map shown
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
    -- transform pixel borders to lat long borders
    newGeoWindow = Types.transformPixelToGeoCoordinateWindow newZoom newPixelWindow
  in
    { oldMapConfiguration
    | zoom = newZoom
    , finalPixelCoordinateWindow = newPixelWindow
    , finalGeoCoordinateWindow = newGeoWindow
    , tileRange = Types.getTileRange newPixelWindow newZoom
    }



newMapForMinusZoom map zoomMinus = 
  let
    relativeZoom = 2 ^ (-zoomMinus)
    zoom = (map.zoom + zoomMinus)
    center = 
      { x = map.window.width // (relativeZoom*2)
      , y = map.window.height // (relativeZoom*2)}
    window =  
      {
        width = map.window.width // relativeZoom
      , height = map.window.height // relativeZoom  
      }
    finalPixelCoordinateWindow = 
      let 
        halfW = map.window.width // (relativeZoom*2)
        halfH = map.window.height // (relativeZoom*2)
        totalPixelHorizontal = (map.finalPixelCoordinateWindow.leftX + map.finalPixelCoordinateWindow.rightX) // 2
        totalPixelVertical = (map.finalPixelCoordinateWindow.topY + map.finalPixelCoordinateWindow.bottomY) // 2
      in
      {
          leftX = totalPixelHorizontal - halfW
        , rightX = totalPixelHorizontal + halfW
        , topY = totalPixelVertical - halfH
        , bottomY = totalPixelVertical + halfH
      }
  in
    updateWholeMapForZoom 
            zoom 
            center
            { map | 
              window =  window
            , finalPixelCoordinateWindow = finalPixelCoordinateWindow
            }



