module Sensor exposing (Sensor, SensorType(..), generateSensorData, init, typeToString, unitToString)

import Random

type SensorType
    = Temperature
    | Humidity
    | Pressure

type alias Sensor =
    { id : Int
    , sensorType : SensorType  -- ✅ Nome correto
    , value : Float
    , error : Maybe String
    }

init : Int -> Sensor
init id =
    let
        sensorType =
            case remainderBy 3 id of  -- ✅ Corrigido aqui
                0 -> Temperature
                1 -> Humidity
                _ -> Pressure
    in
    { id = id
    , sensorType = sensorType
    , value = 0
    , error = Nothing
    }

generateSensorData : Random.Seed -> SensorType -> (Result String Float, Random.Seed)
generateSensorData seed sensorType =
    let
        (errorChance, seed1) = Random.step (Random.float 0 1) seed
        (value, seed2) = Random.step (Random.float 0 1) seed1
        (min, max) = typeRange sensorType
        actualValue = min + (max - min) * value
    in
    if errorChance < 0.1 then
        (Err ("Falha no sensor " ++ typeToString sensorType), seed2)
    else if actualValue < min || actualValue > max then
        (Err ("Valor fora da faixa: " ++ String.fromFloat actualValue), seed2)
    else
        (Ok actualValue, seed2)

typeRange : SensorType -> (Float, Float)
typeRange sensorType =
    case sensorType of
        Temperature -> (20, 80)
        Humidity -> (50, 90)
        Pressure -> (90, 110)

typeToString : SensorType -> String
typeToString sensorType =
    case sensorType of
        Temperature -> "Temperatura"
        Humidity -> "Umidade"
        Pressure -> "Pressão"

unitToString : SensorType -> String
unitToString sensorType =
    case sensorType of
        Temperature -> "°C"
        Humidity -> "%"
        Pressure -> "kPa"