module MousePosition exposing (Model, Msg(..), init, mouseMoveListener, update, view)

import Types
import Html.Events.Extra.Mouse as Mouse
import Html exposing (..)

type alias Model = {x:Float,y:Float}
type Msg = MouseMove Model

init: Model
init = {x=0,y=0}

eventToPosition: Mouse.Event -> Model
eventToPosition event = 
  let (x,y) = event.offsetPos 
  in {x=x,y=y}

mouseMoveListener: Html.Attribute Msg
mouseMoveListener = 
  -- Mouse.onMove (\event -> MouseMove ( eventToPosition event)) -- next line is exactly same
  Mouse.onMove (eventToPosition >> MouseMove)
    
update: Msg -> Model -> Model
update (MouseMove xy) _ = xy

-- it does not produce a Msg so use generic msg
view: Model -> Html msg
view model = div [] 
  [ div [] 
    [ span [] [text "x"] 
    , span [] [text (String.fromFloat model.x) ]
    ]
  , div []
    [ span [] [text "y"] 
    , span [] [text (String.fromFloat model.y) ]
    ]
  ]
  
