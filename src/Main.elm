module Main exposing (..)

import Browser
import Html exposing (Html, button, div, h1, h2, text, span)
import Html.Events exposing (onClick)
import Time
import Sensor exposing (Sensor, SensorType(..), generateSensorData)
import Chart exposing (viewChart)
import Random exposing (Seed, initialSeed, step)
-- Remova ou instale List.Extra conforme explicado acima

-- MODEL
type alias Model =
    { sensors : List Sensor
    , isPaused : Bool
    , errors : List String
    , randomSeed : Random.Seed  -- Adicione esta linha
    }

init : () -> (Model, Cmd Msg)
init _ =
    ( { sensors = []
      , isPaused = False
      , errors = []
      , randomSeed = Random.initialSeed 42  -- Número arbitrário para semente
      }
    , Cmd.none
    )

-- UPDATE
type Msg
    = AddSensor
    | TogglePause
    | ResetSensors
    | Tick Time.Posix
    | SensorError String

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        AddSensor ->
            let
                newSensor = Sensor.init (List.length model.sensors)
            in
            ( { model | sensors = newSensor :: model.sensors }
            , Cmd.none
            )

        TogglePause ->
            ( { model | isPaused = not model.isPaused }
            , Cmd.none
            )

        ResetSensors ->
            ( { model 
              | sensors = List.map (\s -> { s | error = Nothing }) model.sensors
              , errors = []
              }
            , Cmd.none
            )

Tick _ ->
    if model.isPaused then
        (model, Cmd.none)
    else
        let
            (updatedSensors, newSeed) =
                List.foldl
                    (\sensor (sensorsAcc, currentSeed) ->
                        let
                            (result, nextSeed) = 
                                Sensor.generateSensorData currentSeed sensor.sensorType
                            updatedSensor =
                                case result of
                                    Ok newValue ->
                                        { sensor | value = newValue, error = Nothing }
                                    Err err ->
                                        { sensor | error = Just err }
                        in
                        (updatedSensor :: sensorsAcc, nextSeed)
                    )
                    ([], model.randomSeed)
                    model.sensors
        in
        ( { model 
            | sensors = List.reverse updatedSensors
            , randomSeed = newSeed
          }
        , Cmd.none
        )

        SensorError err ->
            ( { model | errors = err :: model.errors }
            , Cmd.none
            )

-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 1000 Tick

-- VIEW
view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Monitoramento Industrial (Elm)" ]
        , button [ onClick TogglePause ]
            [ text (if model.isPaused then "▶ Retomar" else "⏸ Pausar") ]
        , button [ onClick AddSensor ] [ text "➕ Novo Sensor" ]
        , button [ onClick ResetSensors ] [ text "🔁 Resetar" ]
        , div [] (List.map viewSensor model.sensors)
        , viewChart model.sensors
        , div [] (List.map (\e -> div [ class "error" ] [ text e ]) model.errors)
        ]

viewSensor : Sensor -> Html Msg
viewSensor sensor =
    div [ class "sensor" ]
        [ h2 [] [ text (Sensor.typeToString sensor.sensorType) ]  -- ✅ Campo corrigido
        , div [] [ text (String.fromFloat sensor.value ++ " " ++ Sensor.unitToString sensor.sensorType) ]  -- ✅ Campo corrigido
        , case sensor.error of
            Just err ->
                div [ class "error" ] [ text ("❌ " ++ err) ]

            Nothing ->
                div [] [ text "✅ Conectado" ]
        ]

-- MAIN
main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }