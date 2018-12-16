module ElmStyle exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import List exposing (map)

createStyleList : List (String, String) -> List (Html.Attribute msg)
createStyleList list = map (\(key,value) -> (style key value)) list

intToPxString : Int -> String
intToPxString int = (String.fromInt int) ++ "px"