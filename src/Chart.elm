module Chart exposing (viewChart)

import Html exposing (Html, div, text)
import Sensor exposing (Sensor)

viewChart : List Sensor -> Html msg
viewChart sensors =
    div []
        [ text "Gráfico de histórico (implementar com elm-charts ou similar)"
        -- Para gráficos reais, use a biblioteca 'elm-charts'
        ]