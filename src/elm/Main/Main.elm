module Main exposing (Model, Msg(..),  init, main, update, view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events
import Http exposing (Error(..))

import Map exposing(..)
import GenericGeneratorWebcomponent


type alias Model =
    { map: Map.Model
    , dateTimeGlobalTimezoneString: String
    , dateTimeGlobalTimezoneStringNextTimeStep: String
    }



init : Model
init =
    { map = Map.init {}
    , dateTimeGlobalTimezoneString = "2020-10-03T20:05:00"
    , dateTimeGlobalTimezoneStringNextTimeStep = "2020-10-03T20:25:00"
    }


type Msg
    = MapMsg Map.Msg
    | UpdateHtmlDateTime String

update : Msg -> Model -> Model
update message model =
    case message of
        
        UpdateHtmlDateTime dateTime ->
            {model | dateTimeGlobalTimezoneString = dateTime}
        MapMsg mapMsg ->
            {model | map = Map.update mapMsg model.map}


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ 
        -- Html.input 
        --     [ Html.Attributes.type_ "datetime-local"
        --     , value model.dateTimeGlobalTimezoneString
        --     , Html.Events.onInput UpdateHtmlDateTime
        --     ] []
        -- , 
          GenericGeneratorWebcomponent.htmlNode 
            "datetime-picker"
            [ 
                -- GenericGeneratorWebcomponent.onCreated Json.Decode.string TimeDelta
                Html.Attributes.attribute "value" model.dateTimeGlobalTimezoneString
            ]
            []
        , Html.map MapMsg (Map.view model.map model.dateTimeGlobalTimezoneString model.dateTimeGlobalTimezoneStringNextTimeStep)
        -- , img [src "/api/v3/wms/?SERVICE=WMS&REQUEST=GetMap&VERSION=1.1.1&LAYERS=users%3Atom-test-upload-data-18-januari&STYLES=dem_nl&FORMAT=image%2Fpng&TRANSPARENT=false&HEIGHT=256&WIDTH=256&TIME=2020-02-07T10%3A00%3A00&SRS=EPSG%3A3857&BBOX=386465.61500985106,6687322.730613498,391357.5848201024,6692214.700423751"] []
        ]



-- ---------------------------
-- MAIN
-- ---------------------------


main =
    Browser.sandbox
        { init = init
        , view = view
        , update = update
        }
