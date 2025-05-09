module UnitTests exposing (..)

import Expect
import Test exposing (..)
import Sensor exposing (Sensor, generateSensorData)

-- Teste 1: Verifica se valores de temperatura estão na faixa válida
temperatureRangeTest : Test
temperatureRangeTest =
    test "Temperatura deve estar entre 20°C e 80°C" <|
        \_ ->
            case generateSensorData Sensor.Temperature of
                Ok value ->
                    Expect.all
                        [ Expect.greaterThan 20
                        , Expect.lessThan 80
                        ] value

                Err _ ->
                    Expect.fail "Erro inesperado na geração de dados"

-- Suite principal
suite : Test
suite =
    describe "Testes Unitários"
        [ temperatureRangeTest
        ]