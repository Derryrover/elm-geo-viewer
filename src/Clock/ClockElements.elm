module ClockElements exposing (
  hoursToClockParts,
  minutesToClockParts,
  ClockPart,
  ClockPartsHours )

import List

import SelfMadeMath exposing (OddEven(..), isEven, intToOddEven)


type alias Degrees = Int

degreesCircle = 360
hoursEtmal = 12
minutesHour = 60
degreesHour = degreesCircle // hoursEtmal --30
degreesMinute = degreesCircle // minutesHour --6

type alias ClockPart = 
  { start: Degrees
  , end: Degrees
  , oddEven: OddEven
  }

type alias ClockPartsHours = 
  { quarters: List ClockPart
  , singles: List ClockPart
  }

type alias ClockPartsMinutes = 
  { quarters: List ClockPart
  , fivers: List ClockPart
  , minutes: List ClockPart
  }


hourMapToClockPart begin end numberOfKind = 
  { start = begin * degreesHour
  , end = end * degreesHour
  , oddEven = intToOddEven numberOfKind
  }

minutesMapToClockPart begin end numberOfKind = 
  { start = begin * degreesMinute
  , end = end * degreesMinute
  , oddEven = intToOddEven numberOfKind
  }

--hoursToClockParts: Int -> ClockPartsHours
hoursToClockParts hour = 
  let
    hours = List.range 1 hour
    amountQuarters = hour // 3
    amountSingles = remainderBy 3 hour
    quarterList = List.take (3*amountQuarters) hours
    singlesList = List.drop (3*amountQuarters) hours
    quarterList3 = List.filter (\n-> (remainderBy 3 n)== 0) quarterList
    quarterListClockpart = List.map (\n -> (hourMapToClockPart (n-3) n 2) ) quarterList3
    singleListClockParts = List.map (\n -> (hourMapToClockPart (n-1) n (n-3*amountQuarters)) ) singlesList
  in
    { quarters = quarterListClockpart
    , singles = singleListClockParts
    }

minutesToClockParts minute = 
  let
    minutes = List.range 1 minute
    amountQuarters = minute // 15
    amountFivers = (remainderBy 15 minute) // 5
    amountMinutes = remainderBy 5 minute
    quarterList = List.take (15*amountQuarters) minutes
    fiverList = List.take (amountFivers * 5) (List.drop (15*amountQuarters) minutes)
    minutesList = List.drop (amountFivers * 5) (List.drop (3*amountQuarters) minutes)
    quarterList15 = List.filter (\n-> (remainderBy 15 n)== 0) quarterList
    fiverList5 = List.filter (\n-> (remainderBy 5 n)== 0) fiverList
    quarterListClockpart = List.map (\n -> (minutesMapToClockPart (n-15) n 2) ) quarterList15
    fiverListClockParts =  List.map (\n -> (minutesMapToClockPart (n-5) n (n - 15*amountQuarters))) fiverList5
    minutesListClockParts = List.map (\n -> (minutesMapToClockPart (n-1) n (n - 15*amountQuarters - 5* amountFivers))) minutesList
  in
    { quarters = quarterListClockpart
    , fivers = fiverListClockParts
    , minutes = minutesListClockParts
    }




-- HoursStartEndQuartersSingles: HoursStartEndQuartersSingles -> ClockParts
-- HoursStartEndQuartersSingles: listsQS =
--   let 
--     quarters = listsQS.quarters
--     singles = listQS.singles





-- getHoursStartEndQuartersSinglesFromHours: Int -> HoursStartEndQuartersSingles
-- getHoursStartEndQuartersSinglesFromHours h =
--   h 
--     |> getAmountQuartersSinglesFromHours
--     |> getHoursStartEndQuartersSinglesFromAmountQuartersSingles 
     

-- type alias HoursAmountQuartersSingles = 
--   { quarters: Int
--   , singles: Int}

-- getAmountQuartersSinglesFromHours: Int -> HoursAmountQuartersSingles
-- getAmountQuartersSinglesFromHours hours = 
--   { quarters = hours // 3
--   , singles = remainderBy 3 hours 
--   }

-- type alias HoursStartEnd = 
--   { start: Int
--   , end: Int }

-- type alias HoursStartEndQuartersSingles = 
--   { quarters: List HoursStartEnd
--   , singles: List HoursStartEnd
--   }

-- getHoursStartEndQuartersSinglesFromAmountQuartersSingles: HoursAmountQuartersSingles -> HoursStartEndQuartersSingles
-- getHoursStartEndQuartersSinglesFromAmountQuartersSingles rec =
--   let
--     listRangeQ = List.range 1 rec.quarters
--     listStartEndQ = List.map (\i -> {start= (i-1)*3, end= i * 3}) listRangeQ
--     listRangeS = List.range 1 rec.singles
--     listStartEndS = List.map (\i -> {start= i-1, end= i }) listRangeQ
--   in
--     { quarters = listStartEndQ
--     , singles = listStartEndS
--     }
  
  


