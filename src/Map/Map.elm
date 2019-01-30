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
import SizeXYLongLat exposing(getTileRange)
import List
import ProjectionWebMercator exposing(..)
import Types exposing(..)

-- Authentication
import MapboxAuth

map1 = 
  getCompleteMapConfigurationFromWindowAndGeoCoordinates
    { width = 300
    , height = 300
    }
    -- { longLeft = degrees 3.409191 -- west zeeland
    -- , longRight = degrees 24.252712 -- Duitsland?
    -- , latTop = degrees 53.498503 -- Noord Schiermonnikoog
    -- , latBottom = degrees 50.731588 -- Zuid Limburg
    -- }
    { longLeft = degrees 3.409191 -- west zeeland
    , longRight = degrees 7.252712 -- Oost Groningen
    , latTop = degrees 53.498503 -- Noord Schiermonnikoog
    , latBottom = degrees 50.731588 -- Zuid Limburg
    }


  -- { width = 1000
  -- , height = 1000
  -- , longLeft = degrees 3.97705 -- Netherlands
  -- , longRight = degrees 9.98657 -- Hamburg
  -- , latTop = degrees 53.10722 -- Netherlands
  -- , latBottom = degrees 51.27566 -- antwerpen
  -- }

-- map1 =
--   { width = 1000
--   , height = 1000
--   , longLeft = degrees 4.838178 
--   , longRight = degrees 5.705716 
--   , latTop = degrees 53.177070 -- Netherlands Texel
--   , latBottom = degrees 50.740627 -- Aachen
--   }

--_____________________________________________
-- map1 =
--   { width = 1000
--   , height = 1000
--   , longLeft = degrees 3.454511 
--   , longRight = degrees 7.254106 
--   , latTop = degrees 52.379623 -- Netherlands Texel
--   , latBottom = degrees 51.379623 -- Aachen
--   }

-- range0 = getTileRange map1
-- range1 = Debug.log "range" range0
-- mapplog = Debug.log "map1" map1
--_________________________________

-- map2 =
--   { width = 1000
--   , height = 1000
--   , longLeft = degrees 3.97705 -- Netherlands
--   , longRight = degrees 9.98657 -- Hamburg
--   , latTop = degrees 53.10722 -- Netherlands
--   , latBottom = degrees 51.27566 -- antwerpen
--   }
-- mapplog2 = Debug.log "map2" map2
-- mapplog3 = mapplog2


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
  -- let (x,y) = event.pointer.offsetPos clientPos
  let (x,y) = event.pointer.offsetPos
  in y

-- xStart = 0
-- xEnd = 3
-- xRange = List.range xStart xEnd
-- xLength = List.length xRange

-- yStart = 0
-- yEnd = 3
-- yRange = List.range yStart yEnd
-- yLength = List.length yRange


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
        ElmStyle.createStyleList 
          [ ("height", (String.fromInt (map1.finalPixelCoordinates.bottomY - map1.finalPixelCoordinates.topY)) ++ "px")
          , ("width", (String.fromInt (map1.finalPixelCoordinates.rightX - map1.finalPixelCoordinates.leftX))++"px")
          , ("overflow", "hidden")
          , ("position", "relative")
          ] 
      )
      [
        div 
          (
            List.concat [
          [
            Pointer.onDown (\event -> Click (getX event) (getY event))
          ],
          ( 
            ElmStyle.createStyleList 
              [ ("position", "absolute")
              , ("top", (String.fromInt -map1.tileRange.panFromTop)++"px")
              , ("left", (String.fromInt -map1.tileRange.panFromLeft)++"px")
              , ("overflow", "hidden")
              ] 
          )]
          )
        
          (
          List.map
          (
            \y ->
            div
              ( ElmStyle.createStyleList [("pointer-events", "none"),("height", "256px"), ("width", (String.fromInt (256*(List.length map1.tileRange.rangeX)))++"px")] )
              (List.map 
                (
                  \x ->
                  img
                  (
                    List.concat [
                    -- [ src (createMapBoxUrl (Basics.round range1.zoomLevel) x y)
                    [ src (createMapBoxUrl map1.zoom x y)
                    -- , Pointer.onDown (\event -> Click (getX event) (getY event))
                    ]
                    , ( ElmStyle.createStyleList [("pointer-events", "none"),("height", "256px"), ("width", "256px")] )
                    ]
                  )
                  []
                ) 
                map1.tileRange.rangeX
                --range1.x

              )
          )
          map1.tileRange.rangeY
          -- range1.y
        )
        
      ]
      -- , div [] [text (String.fromFloat mapplog2.width)]
    -- div [] [ text (Basics.toString range1)]
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

