module Button exposing (Msg, Model, init, update, view)

import Html exposing (Html, button, text)
import Html.App
import Html.Attributes exposing (disabled)
import Html.Events exposing (onClick)
import Component.Update as Update


-- MODEL


type Msg
    = Click


type alias Model msg' =
    { disabled : Bool
    , onClick : msg'
    }


init : msg' -> Model msg'
init onClick =
    { disabled = False
    , onClick = onClick
    }


enable : Model msg' -> Model msg'
enable model =
    { model | disabled = False }


disable : Model msg' -> Model msg'
disable model =
    { model | disabled = True }



-- UPDATE


update : Msg -> Model msg' -> Update.Action Msg (Model msg') msg'
update msg model =
    case msg of
        Click ->
            Update.return model.onClick



-- VIEW


view : (Msg -> msg) -> Model msg' -> String -> Html msg
view tag model title =
    viewWithContent tag model [ text title ]


viewWithContent : (Msg -> msg) -> Model msg' -> List (Html msg) -> Html msg
viewWithContent tag model content =
    let
        attributes =
            [ onClick (tag Click)
            , disabled model.disabled
            ]
    in
        button attributes content
