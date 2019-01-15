module TestSizeXYLongLat exposing(..)

import SizeXYLongLat exposing(..)

map1 =
  { width = 1000
  , height = 1000
  , longLeft = degrees 3.97705 -- Netherlands
  , longRight = degrees 9.98657 -- Hamburg
  , latTop = degrees 53.10722 -- Netherlands
  , latBottom = degrees 51.27566 -- antwerpen
  }


newMap1 = getAdaptedMapWidthHeight map1

map2 =
  { width = 1000
  , height = 1000
  , longLeft = degrees 3.97705 -- Netherlands
  , longRight = degrees 9.98657 -- Hamburg
  , latTop = degrees 53.10722 -- Netherlands
  , latBottom = degrees 45.27566 --? france ?
  }


newMap2 = getAdaptedMapWidthHeight map2