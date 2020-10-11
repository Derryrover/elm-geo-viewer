port module Main exposing (Model, Msg(..), add1, init, main, toJs, update, view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http exposing (Error(..))
import Json.Decode as Decode

import Map exposing(..)
import DateTimePicker



-- ---------------------------
-- PORTS
-- ---------------------------


port toJs : String -> Cmd msg

port localDateTimePosix: String -> Cmd msg
port receivePosixFromDate : (Int -> msg) -> Sub msg

-- ---------------------------
-- MODEL
-- ---------------------------


type alias Model =
    { counter : Int
    , serverMessage : String
    , map: Map.Model
    , dateTimePicker: DateTimePicker.Model
    , htmlDateTime: String
    , htmlDatePosix: Int
    }


init : Int -> ( Model, Cmd Msg )
init flags =
    let 
      (map, mapCmd) = Map.init ()
      (dateTimePicker, datTimePickerCmd) = DateTimePicker.init ()
    in
    ( { 
        counter = flags, serverMessage = "" 
        , map = map
        , dateTimePicker = dateTimePicker
        , htmlDateTime = "2020-10-10T20:05:00"
        , htmlDatePosix = 0
        }, Cmd.batch [Cmd.none, Cmd.map  MapMsg mapCmd, Cmd.map  DateTimePickerMsg datTimePickerCmd] )



-- ---------------------------
-- UPDATE
-- ---------------------------


type Msg
    = Inc
    | Set Int
    | TestServer
    | OnServerResponse (Result Http.Error String)
    | MapMsg Map.Msg
    | DateTimePickerMsg DateTimePicker.Msg
    | UpdateHtmlDateTime String
    | ReceivePosix Int


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        ReceivePosix posix ->
            ({model | htmlDatePosix = posix}, Cmd.none)
        UpdateHtmlDateTime dateTime ->
            ({model | htmlDateTime = dateTime}, localDateTimePosix dateTime)
        DateTimePickerMsg datTimePickerMsg ->
            let (dateTimePickerModel, dateTimePickerModelMsgNew) = DateTimePicker.update datTimePickerMsg model.dateTimePicker 
            in ({model | dateTimePicker = dateTimePickerModel}, Cmd.map DateTimePickerMsg dateTimePickerModelMsgNew)
        MapMsg mapMsg ->
            let (map, mapMsgNew) = Map.update mapMsg model.map 
            in ({model | map = map}, Cmd.map MapMsg mapMsgNew)
        Inc ->
            ( add1 model, toJs "Hello Js" )

        Set m ->
            ( { model | counter = m }, toJs "Hello Js" )

        TestServer ->
            let
                expect =
                    Http.expectJson OnServerResponse (Decode.field "result" Decode.string)
            in
            ( model
            , Http.get { url = "/test", expect = expect }
            )

        OnServerResponse res ->
            case res of
                Ok r ->
                    ( { model | serverMessage = r }, Cmd.none )

                Err err ->
                    ( { model | serverMessage = "Error: " ++ httpErrorToString err }, Cmd.none )


httpErrorToString : Http.Error -> String
httpErrorToString err =
    case err of
        BadUrl url ->
            "BadUrl: " ++ url

        Timeout ->
            "Timeout"

        NetworkError ->
            "NetworkError"

        BadStatus _ ->
            "BadStatus"

        BadBody s ->
            "BadBody: " ++ s


{-| increments the counter

    add1 5 --> 6

-}
add1 : Model -> Model
add1 model =
    { model | counter = model.counter + 1 }



-- ---------------------------
-- VIEW
-- ---------------------------


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ 
        -- header []
        --     [ -- img [ src "/images/logo.png" ] []
        --       span [ class "logo" ] []
        --     , h1 [] [ text "Elm 0.19.1 Webpack Starter, with hot-reloading" ]
        --     ]
        -- , p [] [ text "Click on the button below to increment the state." ]
        -- , div [ class "pure-g" ]
        --     [ div [ class "pure-u-1-3" ]
        --         [ button
        --             [ class "pure-button pure-button-primary"
        --             , onClick Inc
        --             ]
        --             [ text "+ 1" ]
        --         , text <| String.fromInt model.counter
        --         ]
        --     , div [ class "pure-u-1-3" ] []
        --     , div [ class "pure-u-1-3" ]
        --         [ button
        --             [ class "pure-button pure-button-primary"
        --             , onClick TestServer
        --             ]
        --             [ text "ping dev server" ]
        --         , text model.serverMessage
        --         ]
        --     ]
        -- , p [] [ text "Then make a change to the source code and see how the state is retained after you recompile." ]
        -- , p []
        --     [ text "And now don't forget to add a star to the Github repo "
        --     , a [ href "https://github.com/simonh1000/elm-webpack-starter" ] [ text "elm-webpack-starter" ]
        --     ]
        -- , 
        --   div [class "test_class"] []
        -- , 
        -- Html.map DateTimePickerMsg (DateTimePicker.view model.dateTimePicker)
        Html.input 
            [ Html.Attributes.type_ "datetime-local"
            , value model.htmlDateTime
            , Html.Events.onInput UpdateHtmlDateTime
            ] []
        , Html.map MapMsg (Map.view model.map)
        -- , img [src "/api/v3/wms/?SERVICE=WMS&REQUEST=GetMap&VERSION=1.1.1&LAYERS=users%3Atom-test-upload-data-18-januari&STYLES=dem_nl&FORMAT=image%2Fpng&TRANSPARENT=false&HEIGHT=256&WIDTH=256&TIME=2020-02-07T10%3A00%3A00&SRS=EPSG%3A3857&BBOX=386465.61500985106,6687322.730613498,391357.5848201024,6692214.700423751"] []
        ]



-- ---------------------------
-- MAIN
-- ---------------------------


main : Program Int Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , view =
            \m ->
                { title = "Elm 0.19 starter"
                , body = [ view m ]
                }
        , subscriptions = \model -> Sub.batch[dateToPosixsubscription model ,(Sub.map MapMsg (Map.subscriptions model.map))]
        }

dateToPosixsubscription : Model -> Sub Msg
dateToPosixsubscription _ =
  receivePosixFromDate ReceivePosix