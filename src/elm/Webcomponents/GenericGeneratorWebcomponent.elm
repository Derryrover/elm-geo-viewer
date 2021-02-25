module GenericGeneratorWebcomponent exposing(..)

import Html
import Html.Events
import Json.Decode

htmlNode: String -> List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg
htmlNode str attrs childs = (Html.node str) attrs childs

type RequestState = Idle | Requested | Created | Reset 

requestStateToString: RequestState -> String
requestStateToString status = 
  case status of
    Idle -> "idle"
    Requested -> "requested"
    Created -> "created"
    Reset -> "reset"

--onCreated : Json.Decode.Decoder a -> (a -> msg a) -> Html.Attribute (msg a)
onCreated decoder tagger =
  Html.Events.on "created" (Json.Decode.map tagger (Json.Decode.at [ "detail"] decoder) )

on name decoder tagger =
  Html.Events.on name (Json.Decode.map tagger (Json.Decode.at [ "detail"] decoder) )