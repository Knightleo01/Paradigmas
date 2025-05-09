module Test.Generated.Main exposing (main)

import Example
import UnitTests

import Test.Reporter.Reporter exposing (Report(..))
import Console.Text exposing (UseColor(..))
import Test.Runner.Node
import Test

main : Test.Runner.Node.TestProgram
main =
    Test.Runner.Node.run
        { runs = 100
        , report = ConsoleReport UseColor
        , seed = 12968671514503
        , processes = 8
        , globs =
            []
        , paths =
            [ "C:\\Users\\gab\\Desktop\\Programas\\Paradgmas\\Trabalho 2\\tests\\Example.elm"
            , "C:\\Users\\gab\\Desktop\\Programas\\Paradgmas\\Trabalho 2\\tests\\UnitTests.elm"
            ]
        }
        [ ( "Example"
          , [ Test.Runner.Node.check Example.suite
            ]
          )
        , ( "UnitTests"
          , [ Test.Runner.Node.check UnitTests.temperatureRangeTest
            , Test.Runner.Node.check UnitTests.suite
            ]
          )
        ]