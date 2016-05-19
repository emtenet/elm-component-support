module Counter
    exposing
        ( Msg
        , Model
        , init
        , update
        , view
        , viewWithButtons
        )

import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Component.Update as Update


-- MODEL


type Msg
    = Increment
    | Decrement


type alias Model =
    Int


init : Int -> Model
init value =
    value



-- UPDATE


update : Msg -> Model -> Update.Action Msg Model
update msg model =
    case msg of
        Increment ->
            Update.model (model + 1)

        Decrement ->
            Update.model (model - 1)



-- VIEW


view : (Msg -> msg) -> Model -> Html msg
view tag model =
    div []
        [ button [ onClick (tag Decrement) ] [ text "-" ]
        , div [ countStyle ] [ text (toString model) ]
        , button [ onClick (tag Increment) ] [ text "+" ]
        ]


viewWithButtons : (Msg -> msg) -> Model -> List (Html msg) -> Html msg
viewWithButtons tag model buttons =
    div []
        [ button [ onClick (tag Decrement) ] [ text "-" ]
        , div [ countStyle ] [ text (toString model) ]
        , button [ onClick (tag Increment) ] [ text "+" ]
        , div [ countStyle ] []
        , div [ style [ ( "display", "inline-block" ) ] ] buttons
        ]


countStyle : Attribute msg
countStyle =
    style
        [ ( "font-size", "20px" )
        , ( "font-family", "monospace" )
        , ( "display", "inline-block" )
        , ( "width", "50px" )
        , ( "text-align", "center" )
        ]
