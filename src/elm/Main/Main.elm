module Main exposing (Model, Msg(..),  init, main, update, view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events
import Http exposing (Error(..))

import Map exposing(..)
import GenericGeneratorWebcomponent
import Json.Decode


type alias Model =
    { map: Map.Model
    , posix: Int
    , dateTimeGlobalTimezoneString: String
    , dateTimeGlobalTimezoneStringNextTimeStep: String
    }



init : Model
init =
    { map = Map.init {}
    , posix = 1614692212412
    , dateTimeGlobalTimezoneString = "2020-10-03T20:05:00.000z"
    , dateTimeGlobalTimezoneStringNextTimeStep = "2020-10-03T20:25:00"
    }


type Msg
    = MapMsg Map.Msg
    | UpdateHtmlDateTime String
    | SetPosix Int

update : Msg -> Model -> Model
update message model =
    case message of
        SetPosix int ->
             {model | posix = int}
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
                GenericGeneratorWebcomponent.on "valuechanged" Json.Decode.int SetPosix
             ,   Html.Attributes.attribute "posix" (String.fromInt  model.posix)
            ]
            []
        , div [] [Html.text (String.fromInt model.posix)]
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
