module EmitEvent exposing (..)

import Html
import Html.Events
import Html.Attributes
import Json.Decode

emitEvent event = 
  Html.img 
    [ Html.Attributes.style "display" "none"
    , Html.Attributes.src " data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABAQMAAAAl21bKAAAAA1BMVEUAAACnej3aAAAAAXRSTlMAQObYZgAAAApJREFUCNdjYAAAAAIAAeIhvDMAAAAASUVORK5CYII="
    , Html.Events.on "load" (Json.Decode.succeed event)
    ]
    []