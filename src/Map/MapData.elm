-- example map data

module MapData exposing (..)

import Types exposing (getCompleteMapConfigurationFromWindowAndGeoCoordinateWindow, Window, GeoCoordinateWindow,CompleteMapConfiguration )

map1: CompleteMapConfiguration
map1 = 
  getCompleteMapConfigurationFromWindowAndGeoCoordinateWindow
    { width = 1000
    , height = 1000
    }
    { longLeft = degrees 3.409191 -- west zeeland
    , longRight = degrees 24.252712 -- Duitsland?
    , latTop = degrees 53.498503 -- Noord Schiermonnikoog
    , latBottom = degrees 50.731588 -- Zuid Limburg
    }

map2: CompleteMapConfiguration
map2 = 
  getCompleteMapConfigurationFromWindowAndGeoCoordinateWindow
    { width = 1200
    , height = 800
    }
    -- { longLeft = degrees 3.409191 -- west zeeland
    -- , longRight = degrees 12.252712 -- Oost Groningen
    -- , latTop = degrees 53.498503 -- Noord Schiermonnikoog
    -- , latBottom = degrees 20.731588 -- Italie?
    -- }
    { longLeft = degrees 3.31497114423 
    , longRight = degrees 7.09205325687 
    , latTop = degrees 53.5104033474 
    , latBottom = degrees 50.803721015 
    }

map3: CompleteMapConfiguration
map3 = 
  getCompleteMapConfigurationFromWindowAndGeoCoordinateWindow
    { width = 1000
    , height = 1000
    }
    { longLeft = degrees 3.409191 -- west zeeland
    , longRight = degrees 7.252712 -- Oost Groningen
    , latTop = degrees 53.498503 -- Noord Schiermonnikoog
    , latBottom = degrees 50.731588 -- Zuid Limburg
    }