module Clock exposing (view)

import Html exposing (Html, div, text, input)
import Html.Attributes exposing (style, class,value)
import Svg exposing (circle, line, svg, g)
import Svg.Attributes exposing (..)
-- import SelfMadeMath exposing (OddEven(..))

import Time
import ClockElements exposing (
  hoursToClockParts,
  minutesToClockParts,
  ClockPart,
  ClockPartsHours )
import ClockRenderer exposing(
  renderHours, 
  clockPartWholeCircle )



view: Time.Model -> Html a
view time = 
  let 
    clockPartHours = hoursToClockParts time.hours
    bothHours = List.concat [clockPartHours.quarters, clockPartHours.singles]
    clockPartMinutes = minutesToClockParts time.minutes
    quarterFiverMinutes = List.concat [clockPartMinutes.minutes, clockPartMinutes.fivers, clockPartMinutes.quarters]
  in
    div 
      [] 
      [ svg 
        [ viewBox "-100 -100 200 200", width "300px" ] 
        -- (renderHours bothHours)
        (List.concat 
          [ 
            renderHours clockPartWholeCircle      74 "clock_border"   "clock_border"
          , renderHours clockPartWholeCircle      70 "clock_background"   "clock_background"
          , renderHours clockPartMinutes.minutes  70 "clock_minutes_even"    "clock_minutes_odd"
          , renderHours clockPartMinutes.fivers   70 "clock_minutes_fivers_even"    "clock_minutes_fivers_odd"
          , renderHours clockPartMinutes.quarters 70 "clock_minutes_quarters"    "clock_minutes_quarters"
          , renderHours clockPartWholeCircle      45 "clock_background"   "clock_background"
          , renderHours clockPartWholeCircle      40 "clock_background"   "clock_background"
          , renderHours clockPartHours.singles    40 "clock_hours_main"     "clock_hours_odd"
          , renderHours clockPartHours.quarters   40 "clock_hours_main"     "clock_hours_main"
          ]
        )
      ]

