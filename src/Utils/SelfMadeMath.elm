module SelfMadeMath exposing (OddEven(..), isEven, intToOddEven)

isEven : Int -> Bool
isEven int = modBy 2 int == 0

type OddEven = Odd | Even

intToOddEven i =
  if isEven i then
    Even
  else
    Odd