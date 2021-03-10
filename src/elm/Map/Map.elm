module Map exposing(..)

import Html.Attributes exposing (style, class,value, src, alt, id)
import Html.Events exposing (onInput, onClick)
import Browser exposing(element)
import Html exposing (..)
import Html.Keyed
import Html.Events
import Html.Events.Extra.Pointer as Pointer
import MapBoxUtils exposing (createMapBoxUrl)
-- self made modules
import ElmStyle
import List
import Types 

import CoordinateUtils exposing(Coordinate2d(..), PixelPoint)
import MapBoxUtils exposing (createMapBoxUrl,createWmsUrl, createWmsUrlFromUrl)
import ZoomLevel
import MapLayer

import Json.Decode

import WheelDecoder

-- self made data
import MapData exposing ( map1, map2 )

import Browser
import Browser.Events
import Array
import GenericGeneratorWebcomponent



keyedDiv = Html.Keyed.node "div"

-- main = Browser.element
--   { init = init
--   , view = view
--   , update = update
--   , subscriptions = subscriptions
--   }

type alias Model = 
  { dragStart: PixelPoint
  , dragStartPixels: Types.PixelCoordinateWindow
  , mouseDown: Bool
  , map: Types.CompleteMapConfiguration
  , currentAnimationTimeLeft: Float
  
  , currentAnimationViewBoxLeftX: Float
  , currentAnimationViewBoxTopY: Float
  , currentAnimationViewBoxWidth: Float
  , currentAnimationViewBoxHeight: Float
  
  , currentAnimationZoom: Float
  , currentAnimationLeftX: Float
  , currentAnimationTopY: Float
  , mapLayerModels: List MapLayer.Model
  , temporalMapLayerModel1: MapLayer.Model
  , temporalMapLayerModel2: MapLayer.Model
  , triggerTemporalLayersReadyForNextFrame: Bool
  }

type alias InitModel = {}

type alias DateModel = String


type alias LayerConfif =
  {  urlCreator: Int -> Int -> Int -> String -> String
  , visible: Bool 
  , temporal: Bool
  }

layers: List LayerConfif
layers = 
  [ { urlCreator = createMapBoxUrl
    , visible = True
    , temporal = False
    }
  , { 
      urlCreator = createWmsUrlFromUrl "/api/v3/wms/?SERVICE=WMS&REQUEST=GetMap&VERSION=1.1.1&LAYERS=dem%3Anl&STYLES=dem_nl&FORMAT=image%2Fpng&TRANSPARENT=false&HEIGHT=256&WIDTH=256&TIME=2020-07-19T07%3A47%3A34&SRS=EPSG%3A3857&BBOX="
      -- urlCreator = createWmsUrlFromUrl "https://nxt3.staging.lizard.net/api/v3/wms/?SERVICE=WMS&REQUEST=GetMap&VERSION=1.1.1&LAYERS=dem%3Anl&STYLES=dem_nl&FORMAT=image%2Fpng&TRANSPARENT=false&HEIGHT=256&WIDTH=256&TIME=2020-07-19T07%3A47%3A34&SRS=EPSG%3A3857&BBOX="
    , visible = True
    , temporal = False
    }
  -- , { 
  --   --  urlCreator = createWmsUrlFromUrl "/api/v3/wms/?SERVICE=WMS&REQUEST=GetMap&VERSION=1.1.1&LAYERS=radar%2F5min&STYLES=radar-5min&FORMAT=image%2Fpng&TRANSPARENT=false&HEIGHT=497&WIDTH=525&TIME=2020-08-12T21%3A35%3A00&ZINDEX=20&SRS=EPSG%3A3857&BBOX="
  --   -- urlCreator = createWmsUrlFromUrl "/api/v3/wms/?SERVICE=WMS&REQUEST=GetMap&VERSION=1.1.1&LAYERS=radar%2F5min&STYLES=radar-5min&FORMAT=image%2Fpng&TRANSPARENT=false&HEIGHT=497&WIDTH=525&TIME=2020-08-12T21:35:00&ZINDEX=20&SRS=EPSG%3A3857&BBOX="
  --       urlCreator = createWmsUrlFromUrl "/api/v3/wms/?SERVICE=WMS&REQUEST=GetMap&VERSION=1.1.1&LAYERS=radar%2F5min&STYLES=radar-5min&FORMAT=image%2Fpng&TRANSPARENT=false&HEIGHT=256&WIDTH=256&TIME=${DateTime}&ZINDEX=20&SRS=EPSG%3A3857&BBOX="
  --   , visible = True
  --   , temporal = True
  --   }
  ]

temporalLayer: LayerConfif
temporalLayer = 
    { 
      urlCreator = createWmsUrlFromUrl "/api/v3/wms/?SERVICE=WMS&REQUEST=GetMap&VERSION=1.1.1&LAYERS=radar%2F5min&STYLES=radar-5min&FORMAT=image%2Fpng&TRANSPARENT=false&HEIGHT=256&WIDTH=256&TIME=${DateTime}&ZINDEX=20&SRS=EPSG%3A3857&BBOX="
      -- urlCreator = createWmsUrlFromUrl "https://nxt3.staging.lizard.net/api/v3/wms/?SERVICE=WMS&REQUEST=GetMap&VERSION=1.1.1&LAYERS=radar%2F5min&STYLES=radar-5min&FORMAT=image%2Fpng&TRANSPARENT=false&HEIGHT=256&WIDTH=256&TIME=${DateTime}&ZINDEX=20&SRS=EPSG%3A3857&BBOX="
    , visible = True
    , temporal = True
    }

init : InitModel -> Model
init _ = 
  let 
    map = map2
    zoomFactor = ZoomLevel.getZoomFactor (toFloat map.zoom)
    -- mapLayerData =  List.indexedMap (\_ _ -> MapLayer.init map) layers
    -- mapLayerCmds = List.indexedMap (\ ind (a,b)  -> (Cmd.map (MapLayerMsg ind) b)) mapLayerData
    mapLayerModels = List.map (\_ -> MapLayer.init map) layers
    mapTemporalLayer1Model = MapLayer.init map
    mapTemporalLayer2Model = MapLayer.init map
  in
        { dragStart = 
          { x = 0
          , y = 0
          }
        , dragStartPixels = map.finalPixelCoordinateWindow
        , mouseDown = False
        , map = map
        , currentAnimationTimeLeft = 0.0

        , currentAnimationViewBoxLeftX = (toFloat map.finalPixelCoordinateWindow.leftX)  * zoomFactor
        , currentAnimationViewBoxTopY = (toFloat map.finalPixelCoordinateWindow.topY)  * zoomFactor
        , currentAnimationViewBoxWidth = (toFloat map.window.width)  * zoomFactor
        , currentAnimationViewBoxHeight = (toFloat map.window.height)  * zoomFactor

        , currentAnimationZoom = toFloat map.zoom
        , currentAnimationLeftX = toFloat map.finalPixelCoordinateWindow.leftX
        , currentAnimationTopY = toFloat map.finalPixelCoordinateWindow.topY
        , mapLayerModels = mapLayerModels
        , temporalMapLayerModel1 = mapTemporalLayer1Model
        , temporalMapLayerModel2 = mapTemporalLayer2Model
        , triggerTemporalLayersReadyForNextFrame = False
        }
     

type Msg 
  = 
    TimeDelta Float
  | MouseDown (Float, Float)
  | MouseMove (Float, Float)
  | MouseUp (Float, Float)
  | ZoomLevelMsg ZoomLevel.Msg
  | WheelDecoderMsg WheelDecoder.Msg
  | MapLayerMsg Int MapLayer.Msg
  | TemporalMapLayerMsg1 MapLayer.Msg
  | TemporalMapLayerMsg2 MapLayer.Msg

calculateAnimationValue timeFraction currentValue eventualValue = 
  let
    valueDelta = currentValue - eventualValue
    newValue = currentValue - (timeFraction * valueDelta)
  in
    if currentValue > eventualValue then
      if newValue < eventualValue then
        eventualValue
      else
        newValue
    else 
      if newValue > eventualValue then
        eventualValue
      else
        newValue




update : Msg -> Model -> Model
update msg model = 
  case msg of
    TemporalMapLayerMsg1 mapLayerMessage ->
      {model | temporalMapLayerModel1 = MapLayer.update mapLayerMessage model.temporalMapLayerModel1}
    TemporalMapLayerMsg2 mapLayerMessage ->
      let 
        newModel = {model | temporalMapLayerModel2 = MapLayer.update mapLayerMessage model.temporalMapLayerModel2}
      in
        case mapLayerMessage of 
          MapLayer.AllTilesLoaded _ -> 
            if (MapLayer.areAllDictLoaded model.temporalMapLayerModel1) then
              { newModel | triggerTemporalLayersReadyForNextFrame = True}
            else
              newModel
          _  -> 
            newModel
    MapLayerMsg index mapLayerMessage ->
      let
          oldMapLayerModel = model.mapLayerModels
          mapLayerModels = 
            List.indexedMap 
              (\indexInList item ->  
                if index == indexInList then
                  MapLayer.update mapLayerMessage item
                else
                  item
              ) 
              oldMapLayerModel
      in
      
      { model | mapLayerModels = mapLayerModels}
       
    TimeDelta delta ->
      let
          map = model.map
          
          tempAnimationTimeLeft = model.currentAnimationTimeLeft - delta
          timeFraction = delta / model.currentAnimationTimeLeft
          improvedTimeFraction = 
            if timeFraction > 1 then
              1
            else
              timeFraction
          zoomFactor = ZoomLevel.getZoomFactor (toFloat map.zoom)

          eventualZoom = toFloat model.map.zoom
          eventualLeftX = toFloat model.map.finalPixelCoordinateWindow.leftX
          eventualTopY = toFloat model.map.finalPixelCoordinateWindow.topY
          newZoom = calculateAnimationValue improvedTimeFraction model.currentAnimationZoom eventualZoom
          newLeftX = calculateAnimationValue improvedTimeFraction model.currentAnimationLeftX eventualLeftX
          newTopY = calculateAnimationValue improvedTimeFraction model.currentAnimationTopY eventualTopY
      in
      { model 
        | currentAnimationTimeLeft = 
          if tempAnimationTimeLeft > 0 then
            tempAnimationTimeLeft
          else
            0

        , currentAnimationViewBoxLeftX = 
            calculateAnimationValue 
              improvedTimeFraction 
              model.currentAnimationViewBoxLeftX 
              ((toFloat map.finalPixelCoordinateWindow.leftX)  * zoomFactor)
        , currentAnimationViewBoxTopY = 
            calculateAnimationValue 
              improvedTimeFraction 
              model.currentAnimationViewBoxTopY 
              ((toFloat map.finalPixelCoordinateWindow.topY)  * zoomFactor)
        , currentAnimationViewBoxWidth = 
            calculateAnimationValue 
              improvedTimeFraction 
              model.currentAnimationViewBoxWidth 
              ((toFloat map.window.width)  * zoomFactor)
        , currentAnimationViewBoxHeight = 
            calculateAnimationValue 
              improvedTimeFraction 
              model.currentAnimationViewBoxHeight  
              ((toFloat map.window.height)  * zoomFactor)

        , currentAnimationZoom = newZoom
        , currentAnimationLeftX = newLeftX
        , currentAnimationTopY = newTopY
      } 
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
        zoomFactor = ZoomLevel.getZoomFactor (toFloat map.zoom)
      in
      
      {model 
        | map = newMap
        , currentAnimationTimeLeft = 400 --miliseconds ?

        -- , currentAnimationViewBoxLeftX = (toFloat map.finalPixelCoordinateWindow.leftX)  * zoomFactor
        -- , currentAnimationViewBoxTopY = (toFloat map.finalPixelCoordinateWindow.topY)  * zoomFactor
        -- , currentAnimationViewBoxWidth = (toFloat map.window.width)  * zoomFactor
        -- , currentAnimationViewBoxHeight = (toFloat map.window.height)  * zoomFactor

        , currentAnimationZoom = toFloat model.map.zoom
        , currentAnimationLeftX = toFloat model.map.finalPixelCoordinateWindow.leftX
        , currentAnimationTopY = toFloat model.map.finalPixelCoordinateWindow.topY
        , temporalMapLayerModel1 = MapLayer.update (MapLayer.TileCoordinatesChanged newMap) model.temporalMapLayerModel1
        , temporalMapLayerModel2 = MapLayer.update (MapLayer.TileCoordinatesChanged newMap) model.temporalMapLayerModel2
        , mapLayerModels = List.map (MapLayer.update (MapLayer.TileCoordinatesChanged newMap)) model.mapLayerModels
        }
      
    ZoomLevelMsg plusOrMinus ->
      let 
        map = model.map
        zoom = map.zoom
        newZoom = ZoomLevel.update plusOrMinus zoom
        mapCenter = { x =  map.window.width // 2, y = map.window.height // 2}
        newMap = ZoomLevel.updateWholeMapForZoom newZoom mapCenter map
      in
        {model 
          | map = newMap
          , temporalMapLayerModel1 = MapLayer.update (MapLayer.TileCoordinatesChanged newMap) model.temporalMapLayerModel1
          , temporalMapLayerModel2 = MapLayer.update (MapLayer.TileCoordinatesChanged newMap) model.temporalMapLayerModel2
          , mapLayerModels = List.map (MapLayer.update (MapLayer.TileCoordinatesChanged newMap)) model.mapLayerModels
        }
    MouseDown (x, y) ->
      { model 
          | mouseDown = True
          , dragStart = {x = x, y = y}
          , dragStartPixels = model.map.finalPixelCoordinateWindow
        }
    MouseMove (x, y) ->
      if model.mouseDown == False then
          model
      else
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
            zoomFactor = ZoomLevel.getZoomFactor (toFloat newMap.zoom)
          in
          { model 
              | map = newMap
              , currentAnimationViewBoxLeftX = (toFloat newMap.finalPixelCoordinateWindow.leftX)  * zoomFactor
              , currentAnimationViewBoxTopY = (toFloat newMap.finalPixelCoordinateWindow.topY)  * zoomFactor
              , currentAnimationViewBoxWidth = (toFloat newMap.window.width)  * zoomFactor
              , currentAnimationViewBoxHeight = (toFloat newMap.window.height)  * zoomFactor
              , temporalMapLayerModel1 = MapLayer.update (MapLayer.TileCoordinatesChanged newMap) model.temporalMapLayerModel1
              , temporalMapLayerModel2 = MapLayer.update (MapLayer.TileCoordinatesChanged newMap) model.temporalMapLayerModel2
              , mapLayerModels = List.map (MapLayer.update (MapLayer.TileCoordinatesChanged newMap)) model.mapLayerModels
            }
           
    MouseUp (x, y) ->
      { model 
          | mouseDown = False
        }
       

createLayerHelper model layer urlFunction dateModel =
  MapLayer.mapLayer
    layer 
    model.map 
    urlFunction
    dateModel           
    model.currentAnimationZoom 
    model.currentAnimationLeftX 
    model.currentAnimationTopY
    
    model.currentAnimationViewBoxLeftX
    model.currentAnimationViewBoxTopY
    model.currentAnimationViewBoxWidth
    model.currentAnimationViewBoxHeight

view : Model -> DateModel -> DateModel -> Html Msg
view model dateModel nextStepDateModel = 
  let
    maxTilesOnAxis = Types.tilesFromZoom model.map.zoom
    map = model.map
    layerViews = 
      List.map2 
        (\modelLayer config -> 
          createLayerHelper
            model
            modelLayer
            config.urlCreator
            dateModel
        )    
        model.mapLayerModels 
        layers         
    temporalLayerView1 = 
      ( createLayerHelper
            model
            model.temporalMapLayerModel1
            temporalLayer.urlCreator
            dateModel
      )
    temporalLayerView2 = 
      ( createLayerHelper
            model
            model.temporalMapLayerModel2
            temporalLayer.urlCreator
            nextStepDateModel
      )
    mapTemporalLayerToUse = 
      if (MapLayer.areAllDictLoaded model.temporalMapLayerModel2 && MapLayer.areAllDictLoaded model.temporalMapLayerModel1) then
        Html.map (TemporalMapLayerMsg2) temporalLayerView2
      else
        Html.map (TemporalMapLayerMsg1) temporalLayerView1
  in
  div 
    []
    [ 
      -- CoordinateUtils.view model.dragStart map.window.width map.finalPixelCoordinateWindow.rightX
      -- CoordinateUtils.view {x=model.currentAnimationTimeLeft, y=model.currentAnimationZoom} map.window.width map.finalPixelCoordinateWindow.rightX
    -- , CoordinateUtils.view model.dragStart map.finalPixelCoordinateWindow.rightX map.finalPixelCoordinateWindow.bottomY
    --, Html.map ZoomLevelMsg (ZoomLevel.view model.map.zoom)
    -- , 
    div
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
          , Pointer.onLeave
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
      (List.concat [
        (List.indexedMap 
          (\ind layerView -> Html.map (MapLayerMsg ind) layerView) 
          layerViews
        )
        , [ mapTemporalLayerToUse]
      ])
      
      , div 
         (ElmStyle.createStyleList 
           [ ("display", "none" )]
         )
        
        [ Html.map (TemporalMapLayerMsg2) temporalLayerView2
        , Html.map (TemporalMapLayerMsg1) temporalLayerView1
        ]
      , if model.currentAnimationTimeLeft /= 0 then
          GenericGeneratorWebcomponent.htmlNode 
            "requestanimframe-component"
            [ GenericGeneratorWebcomponent.onCreated Json.Decode.float TimeDelta
            ]
            []
        else 
          Html.node "empty-element" [] []
      
    ]



