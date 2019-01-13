module ProjectionWebMercator exposing(..)

-- pi = Basics.pi
-- tan = Basics.tan
-- atan2 = Basics.atan2
-- abs = Basics.abs
ln x = Basics.logBase Basics.e x


longToX x zoom = 
  (256/(2*pi)) * 2^zoom * (x + pi)

latToY y zoom = 
  (256/(2*pi)) * 2^zoom * (pi- (ln(abs(tan(pi/4 + y/2)))))