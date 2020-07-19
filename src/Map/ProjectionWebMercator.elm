module ProjectionWebMercator exposing(..)


ln x = Basics.logBase Basics.e x


-- all below coordinates in radians
longToX long zoomInt = 
  let zoom = toFloat zoomInt
  in (256/(2*pi)) * 2^zoom * (long + pi)

xToLong xInt zoomInt =
  let
    x = toFloat xInt
    zoom = toFloat zoomInt
  in
  
  (x / ((256/(2*pi)) * 2^zoom) ) - pi


latToY lat zoomInt = 
  let zoom = toFloat zoomInt
  in (256/(2*pi)) * 2^zoom * (pi- (ln(abs(tan(pi/4 + lat/2)))))

-- how do I inverse a absolute or is that even possible..
-- the function yToLat seems to work if identity function is used so maybe it is okey
inverseAbs x = x

yToLat yInt zoomInt = 
  let 
    y = toFloat yInt
    zoom = toFloat zoomInt
    temp = y / ((256/(2*pi)) * 2^zoom)
    temp2 = pi - temp
    temp3 = e^temp2
    temp4 = inverseAbs temp3
    temp5 = atan temp4
    temp6 = temp5 - pi/4
    temp7 = temp6 * 2
  in
    temp7



-- For below to functions used this gist as example:
-- https://gist.github.com/springmeyer/871897
longToMeters lon = 
  lon * 20037508.34 / 180
    

latToMeters lat = 
  let
    y = ln (tan((90 + lat) * pi / 360)) / (pi / 180)
    y2 = y * 20037508.34 / 180
  in 
    y2