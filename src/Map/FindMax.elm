module FindMax exposing(..)

import List exposing(..)
import Maybe exposing(..)


exampleMax = findMax [1,23,4,5,6,7,77,8,9, 1,23,4,5,6,7,77,8,91,23,4,5,6,7,77,8,91,23,4,5,6,7,77,8,91,23,4,5,6,7,77,8,91,23,4,5,6,7,77,8,91,23,4,5,6,7,77,8,91,23,4,5,6,7,77,8,91,23,4,5,6,7,77,8,91,23,4,5,6,7,77,8,91,23,4,5,6,7,77,8,91,23,4,5,6,7,77,8,91,23,4,5,6,7,77,8,91,23,4,5,6,7,77,8,91,23,4,5,6,7,77,8,91,23,4,5,6,7,77,8,91,23,4,5,6,7,77,8,91,23,4,5,6,7,77,8,91,23,4,5,6,7,77,8,91,23,4,5,6,7,77,8,91,23,4,5,6,7,77,8,91,23,4,5,6,7,77,8,91,23,4,5,6,7,77,8,91,23,4,5,6,7,77,8,91,23,100,4,5,6,7,77,8,91,23,4,5,6,7,77,8,91,23,4,5,6,7,77,8,91,23,4,5,6,7,77,1000,8,91,23,4,5,6,7,77,8,9]

findMax: List Int -> Maybe Int
findMax list = 
  let
    initialHeadMaybe = head list
  in
    case initialHeadMaybe of 
      Nothing ->
        Nothing
      Just head ->
        let
          maybeTail = tail list
        in
          case maybeTail of 
            Nothing ->
              Just head
            Just tailList ->
              Just (findMaxHelper head tailList)

findMaxHelper: Int -> List Int -> Int
findMaxHelper old list = 
  let
    initialHeadMaybe = head list
  in
    case initialHeadMaybe of 
      Nothing ->
        old
      Just head ->
        let
          tempMax = 
            if old > head   then 
              old
            else
              head
          maybeTail = tail list
        in
          case maybeTail of 
            Nothing ->
              tempMax
            Just tailList ->
              findMaxHelper tempMax tailList


        







