module CoordinateViewer exposing (view)

import Html exposing (..)
import ProjectionWebMercator exposing(..)

view x y zoom = 
  let
    long = (xToLong (round x) zoom)
    lat = (yToLat (round y) zoom)
    xCalc = longToX long zoom
    yCalc = latToY lat zoom
  in
    div
      []
      [ div 
          [] 
          [  text "x: "
          , text (String.fromFloat x )
          ]
      , div 
          []
          [ text "y: "
          , text (String.fromFloat y )
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
      ]     