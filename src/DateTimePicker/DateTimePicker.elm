module DateTimePicker exposing (..)

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

week1 = List.range 1 13
week2 = List.range 8 20
week3 = List.range 15 27
week4 = List.range 22 31
week5 = List.range 29 31

type alias Model = 
  { 
    -- opened: Bool
  -- , 
    year: Int,
  , mont: Month
  }