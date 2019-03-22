-- example map data

module MapData exposing (..)

import Types exposing (getCompleteMapConfigurationFromWindowAndGeoCoordinates, Window, GeoCoordinates,CompleteMapConfiguration )

map2: CompleteMapConfiguration
map2 = 
  getCompleteMapConfigurationFromWindowAndGeoCoordinates
    { width = 800
    , height = 400
    }
    { longLeft = degrees 3.409191 -- west zeeland
    , longRight = degrees 12.252712 -- Oost Groningen
    , latTop = degrees 53.498503 -- Noord Schiermonnikoog
    , latBottom = degrees 20.731588 -- Italie?
    }

map1: CompleteMapConfiguration
map1 = 
  getCompleteMapConfigurationFromWindowAndGeoCoordinates
    { width = 1000
    , height = 1000
    }
    { longLeft = degrees 3.409191 -- west zeeland
    , longRight = degrees 24.252712 -- Duitsland?
    , latTop = degrees 53.498503 -- Noord Schiermonnikoog
    , latBottom = degrees 50.731588 -- Zuid Limburg
    }

map3: CompleteMapConfiguration
map3 = 
  getCompleteMapConfigurationFromWindowAndGeoCoordinates
    { width = 1000
    , height = 1000
    }
    { longLeft = degrees 3.409191 -- west zeeland
    , longRight = degrees 7.252712 -- Oost Groningen
    , latTop = degrees 53.498503 -- Noord Schiermonnikoog
    , latBottom = degrees 50.731588 -- Zuid Limburg
    }