module ClockRenderer exposing (renderHours, clockPartWholeCircle)

import Html exposing (Html, div, text, input)
import Html.Attributes exposing (style,value)
import Svg exposing (circle, line, svg, g)
import Svg.Attributes exposing (..)
import SelfMadeMath exposing (OddEven(..))

import List

import ClockElements exposing (
  hoursToClockParts,
  ClockPart,
  ClockPartsHours )

-- radius = 50
-- radiusString = String.fromInt radius

renderHour clockPart radius evenColor oddColor = 
  let
    radiusString = String.fromFloat radius
    beginX = String.fromFloat (radius*(cos(degrees(toFloat (clockPart.start - 90)))))
    beginY = String.fromFloat (radius*(sin(degrees(toFloat (clockPart.start - 90)))))
    endX   = String.fromFloat (radius*(cos(degrees(toFloat (clockPart.end - 90)))))
    endY   = String.fromFloat (radius*(sin(degrees(toFloat (clockPart.end - 90)))))
    fillColor = 
      case clockPart.oddEven of
        Even -> evenColor
        Odd  -> oddColor 
    classColor = 
      case clockPart.oddEven of
        Even -> evenColor
        Odd  -> oddColor
  in
  g 
    [ stroke "none"
    -- , fill fillColor
    , class classColor]
    [ Svg.path
      [ d 
          (
            "M 0 0 " ++
            "L "++beginX++" "++beginY++" "++
            "A "++radiusString++" "++radiusString++" 0 0 1 "++endX++" "++endY++" "++
            "L "++endX++" "++endY++" "
          )
          -- """
          -- M 0 0
          -- l clockPart.begin 50
          -- A 40 40 0 1 1 50 90
          -- L 10 50
          -- Z
          -- """
      ] 
      []
    ] 

renderHours clockParts radius evenColor oddColor= 
  List.map (\n-> renderHour n radius evenColor oddColor) clockParts

clockPartWholeCircle = 
  [
    { start = 0
    , end = 90
    , oddEven = Odd
    }
    ,
    { start = 90
    , end = 180
    , oddEven = Odd
    }
    ,
    { start = 180
    , end = 270
    , oddEven = Odd
    }
    ,
    { start = 270
    , end = 360
    , oddEven = Odd
    }
  ]

