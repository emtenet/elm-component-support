module Main exposing (..)

import Html exposing (Html)
import Html.Attributes
import Component.App
import Component.Update as Update
import Messages


main =
    Component.App.program
        { init = Messages.init
        , update = Messages.update
        , view = view
        , subscriptions = Messages.subscriptions
        }


view : (Messages.Msg -> msg) -> Messages.Model -> Html msg
view tag model =
    Html.div [ style ]
        [ Html.h1 [] [ Html.text "Elm echo sample" ]
        , Messages.view tag model
        ]


style : Html.Attribute msg
style =
    Html.Attributes.style
        [ ( "maxWidth", "300px" )
        , ( "margin", "0px auto" )
        ]
