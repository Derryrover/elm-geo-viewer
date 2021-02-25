module ElmStyle exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import List

createStyleList : List (String, String) -> List (Html.Attribute msg)
createStyleList list = List.map (\(key,value) -> (style key value)) list

intToPxString : Int -> String
intToPxString int = (String.fromInt int) ++ "px"