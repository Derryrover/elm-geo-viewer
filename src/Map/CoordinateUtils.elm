module CoordinateUtils exposing (..)

import Html exposing (..)

type Coordinate2d = X | Y

type alias PixelPoint =
  { x: Float
  , y: Float 
  }

view: PixelPoint -> Int -> Int -> Html x
view pixelPoint x y =
  div
      []
      [ div 
          [] 
          [  text "x: "
          , text (String.fromFloat pixelPoint.x )
          ]
      , div 
          []
          [ text "y: "
          , text (String.fromFloat pixelPoint.y )
          ]
      , div 
          []
          [ text "left: "
          , text (String.fromInt x )
          ]
      , div 
          []
          [ text "top: "
          , text (String.fromInt y )
          ]
      ]