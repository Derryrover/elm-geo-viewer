module DateTimePicker exposing (..)

import Html
import Time
import DateTime

type Month =
  Januari |
  Februari |
  March | 
  April |
  May |
  June |
  July |
  Augustus |
  September |
  October |
  November | 
  December

months: List Month
months = 
  [ Januari 
  , Februari 
  , March 
  , April 
  , May 
  , June 
  , July 
  , Augustus 
  , September 
  , October 
  , November 
  , December
  ]

-- implement later, maybe it is no use because of translations
monthToString: Month -> String
monthToString month = ""

type WeekDay = 
    Monday 
  | Tuesday
  | Wednesday
  | Thursday
  | Friday
  | Saturday
  | Sunday

weekdays: List WeekDay
weekdays = 
  [ Monday 
  , Tuesday
  , Wednesday
  , Thursday
  , Friday
  , Saturday
  , Sunday
  ]


-- week1 = List.range 1 13
-- week2 = List.range 8 20
-- week3 = List.range 15 27
-- week4 = List.range 22 31
-- week5 = List.range 29 31
week1 = List.range -5 7
week2 = List.range 2 14
week3 = List.range 9 21
week4 = List.range 16 28
week5 = List.range 23 31
week6 = List.range 30 31

type alias Model = 
  { 
    -- opened: Bool
  -- , 
    openYear: Int
  , openMonth: Month
  , numberOfDaysInOpenMonth: Int
  , firstWeekDayOfMonth: WeekDay
  }

init : () -> (Model, Cmd Msg)
init _ = 
  ({ 
    openYear = 2020
  , openMonth = Januari
  , numberOfDaysInOpenMonth = 29
  , firstWeekDayOfMonth = Tuesday
  }, Cmd.none)

type Msg = SetOpenMonth Month | SetOpenYear Int

update: Msg -> Model -> ( Model, Cmd Msg )
update msg model = 
  case msg of
    SetOpenMonth month ->
      ({ model | openMonth = month }, Cmd.none)
    SetOpenYear year ->
      ({ model | openYear = year }, Cmd.none)

view : Model -> Html.Html Msg
view model = 
  Html.div [] 
    [ Html.table []
      [ Html.tbody [] 
        [ Html.tr [] (List.map (\day -> (Html.td [] [Html.text (if day > 0 then (String.fromInt day) else "")])) week1 )
        , Html.tr [] (List.map (\day -> (Html.td [] [Html.text (String.fromInt day)])) week2 )
        , Html.tr [] (List.map (\day -> (Html.td [] [Html.text (String.fromInt day)])) week3 )
        , Html.tr [] (List.map (\day -> (Html.td [] [Html.text (String.fromInt day)])) week4 )
        , Html.tr [] (List.map (\day -> (Html.td [] [Html.text (if day <= model.numberOfDaysInOpenMonth then (String.fromInt day) else "")])) week5 )
        , Html.tr [] (List.map (\day -> (Html.td [] [Html.text (if day <= model.numberOfDaysInOpenMonth then (String.fromInt day) else "")])) week6 )
        ]
      ]
    ]


monthToInt : Time.Month -> Int
monthToInt month =
  case month of
    Time.Jan -> 1
    Time.Feb -> 2
    Time.Mar -> 3
    Time.Apr -> 4
    Time.May -> 5
    Time.Jun -> 6
    Time.Jul -> 7
    Time.Aug -> 8
    Time.Sep -> 9
    Time.Oct -> 10
    Time.Nov -> 11
    Time.Dec -> 12

dateIntToString: Int -> String
dateIntToString integ = 
  if integ < 10 then "0" ++ (String.fromInt integ)
  else String.fromInt integ

dateTimeToString: DateTime.DateTime -> String
dateTimeToString dateTime = 
  let
    year = dateIntToString (DateTime.getYear dateTime)
    month = dateIntToString (monthToInt (DateTime.getMonth dateTime))
    day = dateIntToString (DateTime.getDay dateTime)
    hour = dateIntToString (DateTime.getHours dateTime)
    minute  = dateIntToString (DateTime.getMinutes dateTime)
    second = dateIntToString (DateTime.getSeconds dateTime)
  in
    year++"-"++month++"-"++day++"T"++hour++":"++minute++":"++second