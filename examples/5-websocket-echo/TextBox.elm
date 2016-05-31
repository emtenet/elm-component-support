module TextBox
    exposing
        ( Msg
        , Model
        , Option
        , init
        , onEnter
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


type alias Model msg' =
    { id : String
    , focused : Bool
    , text : String
    , onEnter : Maybe msg'
    }


type Option msg'
    = OnEnter msg'


init : String -> List (Option msg') -> Model msg'
init id options =
    initOptions options
        { id = id
        , focused = False
        , text = ""
        , onEnter = Nothing
        }


onEnter : msg' -> Option msg'
onEnter =
    OnEnter


initOptions : List (Option msg') -> Model msg' -> Model msg'
initOptions options model =
    case options of
        [] ->
            model

        (OnEnter msg) :: rest ->
            initOptions rest { model | onEnter = Just msg }


text : Model msg' -> String
text model =
    model.text


textSetAs : String -> Model msg' -> Model msg'
textSetAs text model =
    { model | text = text }


textSetAsEmpty : Model msg' -> Model msg'
textSetAsEmpty =
    textSetAs ""



-- UPDATE


update : Msg -> Model msg' -> Update.Action Msg (Model msg') msg'
update msg model =
    case msg of
        Text text ->
            Update.model (textSetAs text model)

        KeyPress key ->
            if key == 13 then
                Update.returnMaybe model.onEnter
            else
                Update.ignore

        Focus ->
            Update.model { model | focused = True }

        Blur ->
            Update.model { model | focused = False }



-- VIEW


view : (Msg -> msg) -> Model msg' -> String -> Html msg
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


viewLabel : Model msg' -> String -> Html msg
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


viewInput : (Msg -> msg) -> Model msg' -> Html msg
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


viewUnderline : Model msg' -> Html msg
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
