module TextBox
    exposing
        ( Msg(EnterPressed)
        , Model
        , init
        , text
        , textSetAs
        , textSetAsEmpty
        , update
        , view
        )

import Html exposing (Html, input)
import Html.Attributes exposing (value)
import Html.Events exposing (onInput, onFocus, onBlur)
import Json.Decode
import Component.Update as Update


-- MODEL


type Msg
    = Text String
    | KeyPress Int
    | Focus
    | Blur
      -- public messages
    | EnterPressed


type alias Model =
    { id : String
    , focused : Bool
    , text : String
    }


init : String -> Model
init id =
    initWithText id ""


initWithText : String -> String -> Model
initWithText id text =
    { id = id
    , focused = False
    , text = text
    }


text : Model -> String
text model =
    model.text


textSetAs : String -> Model -> Model
textSetAs text model =
    { model | text = text }


textSetAsEmpty : Model -> Model
textSetAsEmpty =
    textSetAs ""



-- UPDATE


update : Msg -> Model -> Update.Action Msg Model
update msg model =
    case msg of
        Text text ->
            Update.model (textSetAs text model)

        KeyPress key ->
            if key == 13 then
                Update.event EnterPressed
            else
                Update.ignore

        Focus ->
            Update.model { model | focused = True }

        Blur ->
            Update.model { model | focused = False }

        EnterPressed ->
            Update.eventIgnored



-- VIEW


view : (Msg -> msg) -> Model -> String -> Html msg
view tag model title =
    Html.div
        [ Html.Attributes.style
            [ ( "display", "inline-block" )
            , ( "padding", "4px" )
            ]
        ]
        [ viewLabel model title
        , viewInput tag model
        , viewUnderline model
        ]


viewLabel : Model -> String -> Html msg
viewLabel model title =
    Html.div
        [ Html.Attributes.style
            [ ( "color", "#000000" )
            , ( "fontSize", "14px" )
            , ( "height", "14px" )
            , ( "lineHeight", "14px" )
            ]
        ]
        [ Html.label [ Html.Attributes.for model.id ]
            [ Html.text title ]
        ]


viewInput : (Msg -> msg) -> Model -> Html msg
viewInput tag model =
    let
        onKeyPress tagger =
            Html.Events.on "keypress" (Json.Decode.map tagger Html.Events.keyCode)
    in
        Html.input
            [ Html.Attributes.id model.id
            , onInput (tag << Text)
            , onKeyPress (tag << KeyPress)
            , onFocus (tag Focus)
            , onBlur (tag Blur)
            , value model.text
            , Html.Attributes.style
                [ ( "backgroundColor", "transparent" )
                , ( "border", "none" )
                , ( "color", "#2196f3" )
                , ( "fontSize", "16px" )
                , ( "lineHeight", "24px" )
                , ( "outline", "none" )
                , ( "padding", "0px" )
                , ( "width", "100%" )
                ]
            ]
            []


viewUnderline : Model -> Html msg
viewUnderline model =
    Html.div
        [ Html.Attributes.style
            [ ( "height", "2px" )
            , ( "position", "relative" )
            , ( "width", "100%" )
            ]
        ]
        [ Html.div
            [ Html.Attributes.style
                [ ( "borderBottom", "none" )
                , ( "borderLeft", "none" )
                , ( "borderRight", "none" )
                , ( "borderTop", "solid 1px #e0e0e0" )
                , ( "height", "1px" )
                , ( "margin", "0px" )
                , ( "width", "100%" )
                ]
            ]
            []
        , Html.div
            [ Html.Attributes.style
                [ ( "borderBottom", "none" )
                , ( "borderLeft", "none" )
                , ( "borderRight", "none" )
                , ( "borderTop", "solid 2px #ffc107" )
                , ( "height", "0px" )
                , ( "left"
                  , if model.focused then
                        "0px"
                    else
                        "50%"
                  )
                , ( "margin", "0px" )
                , ( "position", "absolute" )
                , ( "top", "0px" )
                , ( "transitionDuration", "450ms" )
                , ( "transitionProperty", "left, width" )
                , ( "width"
                  , if model.focused then
                        "100%"
                    else
                        "0px"
                  )
                ]
            ]
            []
        ]
