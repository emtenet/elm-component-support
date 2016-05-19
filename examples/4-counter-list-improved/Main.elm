module Main exposing (..)

import Html exposing (Html)
import Html.Attributes
import Component.App
import CounterList


main =
    Component.App.beginnerProgram
        { init = CounterList.init
        , view = view
        , update = CounterList.update
        }


view : (CounterList.Msg -> msg) -> CounterList.Model -> Html msg
view tag model =
    Html.div [ style ] [ CounterList.view tag model ]


style : Html.Attribute msg
style =
    Html.Attributes.style
        [ ( "maxWidth", "300px" )
        , ( "margin", "0px auto" )
        ]
