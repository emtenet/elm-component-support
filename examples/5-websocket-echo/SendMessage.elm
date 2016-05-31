module SendMessage
    exposing
        ( Msg
        , Model
        , init
        , update
        , view
        )

import Html exposing (..)
import Component.Update as Update
import Button
import TextBox


-- MODEL


type Msg
    = Message TextBox.Msg
    | Send Button.Msg
    | SendClicked


type alias Model msg' =
    { message : TextBox.Model Msg
    , send : Button.Model Msg
    , onSend : String -> msg'
    }


init : (String -> msg') -> Model msg'
init onSend =
    { message = TextBox.init "message-text" [ TextBox.onEnter SendClicked ]
    , send = Button.init SendClicked
    , onSend = onSend
    }



-- UPDATE


update : Msg -> Model msg' -> Update.Action Msg (Model msg') msg'
update msg model =
    case msg of
        Message msg' ->
            Update.component msg' model.message (Message) (\x -> { model | message = x }) TextBox.update

        Send msg' ->
            Update.component msg' model.send (Send) (\x -> { model | send = x }) Button.update

        SendClicked ->
            let
                message =
                    TextBox.text model.message
            in
                Update.modelAndReturn { model | message = TextBox.textSetAsEmpty model.message }
                    (model.onSend message)



-- VIEW


view : (Msg -> msg) -> Model msg' -> Html msg
view tag model =
    div []
        [ Html.p [] [ Html.text "Type a message then press Enter or click Send" ]
        , TextBox.view (tag << Message) model.message "Message to send"
        , Button.view (tag << Send) model.send "Send"
        ]
