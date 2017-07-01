module TestCeilCom exposing (ceilComTest)

import Test exposing (..)
import Expect exposing (equal)
import TestFunction exposing (testFunction)
import Round


data =
    [ ( 0, "0", "0", "0", "0.0", "0.00" )
    , ( 0, "0", "0", "0", "0.0", "0.00" )
    , ( 0, "0", "0", "0", "0.0", "0.00" )
    , ( 0, "0", "0", "0", "0.0", "0.00" )
    , ( 0, "0", "0", "0", "0.0", "0.00" )
    , ( 99, "100", "100", "99", "99.0", "99.00" )
    , ( 9.9, "100", "10", "10", "9.9", "9.90" )
    , ( 0.99, "100", "10", "1", "1.0", "0.99" )
    , ( 0.099, "100", "10", "1", "0.1", "0.10" )
    , ( 0.0099, "100", "10", "1", "0.1", "0.01" )
    , ( -99, "-100", "-100", "-99", "-99.0", "-99.00" )
    , ( -9.9, "-100", "-10", "-10", "-9.9", "-9.90" )
    , ( -0.99, "-100", "-10", "-1", "-1.0", "-0.99" )
    , ( -0.099, "-100", "-10", "-1", "-0.1", "-0.10" )
    , ( -0.0099, "-100", "-10", "-1", "-0.1", "-0.01" )
    , ( 1, "100", "10", "1", "1.0", "1.00" )
    , ( 1.1, "100", "10", "2", "1.1", "1.10" )
    , ( 1.01, "100", "10", "2", "1.1", "1.01" )
    , ( 1.001, "100", "10", "2", "1.1", "1.01" )
    , ( -1, "-100", "-10", "-1", "-1.0", "-1.00" )
    , ( -1.1, "-100", "-10", "-2", "-1.1", "-1.10" )
    , ( -1.01, "-100", "-10", "-2", "-1.1", "-1.01" )
    , ( -1.001, "-100", "-10", "-2", "-1.1", "-1.01" )
    , ( 213, "300", "220", "213", "213.0", "213.00" )
    , ( 213.1, "300", "220", "214", "213.1", "213.10" )
    , ( 213.01, "300", "220", "214", "213.1", "213.01" )
    , ( 213.001, "300", "220", "214", "213.1", "213.01" )
    , ( -213, "-300", "-220", "-213", "-213.0", "-213.00" )
    , ( -213.1, "-300", "-220", "-214", "-213.1", "-213.10" )
    , ( -213.01, "-300", "-220", "-214", "-213.1", "-213.01" )
    , ( -213.001, "-300", "-220", "-214", "-213.1", "-213.01" )
    , ( 5.5, "100", "10", "6", "5.5", "5.50" )
    , ( 5.55, "100", "10", "6", "5.6", "5.55" )
    , ( 5.555, "100", "10", "6", "5.6", "5.56" )
    , ( 5.5555, "100", "10", "6", "5.6", "5.56" )
    , ( -5.5, "-100", "-10", "-6", "-5.5", "-5.50" )
    , ( -5.55, "-100", "-10", "-6", "-5.6", "-5.55" )
    , ( -5.555, "-100", "-10", "-6", "-5.6", "-5.56" )
    , ( -5.5555, "-100", "-10", "-6", "-5.6", "-5.56" )
    , ( 5.5, "100", "10", "6", "5.5", "5.50" )
    , ( 5.51, "100", "10", "6", "5.6", "5.51" )
    , ( 5.501, "100", "10", "6", "5.6", "5.51" )
    , ( 5.5001, "100", "10", "6", "5.6", "5.51" )
    , ( -5.5, "-100", "-10", "-6", "-5.5", "-5.50" )
    , ( -5.51, "-100", "-10", "-6", "-5.6", "-5.51" )
    , ( -5.501, "-100", "-10", "-6", "-5.6", "-5.51" )
    , ( -5.5001, "-100", "-10", "-6", "-5.6", "-5.51" )
    , ( 4.9, "100", "10", "5", "4.9", "4.90" )
    , ( 4.99, "100", "10", "5", "5.0", "4.99" )
    , ( 4.999, "100", "10", "5", "5.0", "5.00" )
    , ( 4.9999, "100", "10", "5", "5.0", "5.00" )
    , ( -4.9, "-100", "-10", "-5", "-4.9", "-4.90" )
    , ( -4.99, "-100", "-10", "-5", "-5.0", "-4.99" )
    , ( -4.999, "-100", "-10", "-5", "-5.0", "-5.00" )
    , ( -4.9999, "-100", "-10", "-5", "-5.0", "-5.00" )
    ]


ceilComTest : Test
ceilComTest =
    testFunction "ceilingCom" Round.ceilingCom data
