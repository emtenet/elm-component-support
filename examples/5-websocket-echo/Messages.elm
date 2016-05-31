module Messages
    exposing
        ( Msg
        , Model
        , init
        , update
        , subscriptions
        , view
        )

import Html exposing (Html)
import Html.Attributes
import WebSocket
import SendMessage as Sender
import Component.Update as Update
import Message


-- MODEL


type Msg
    = Sender Sender.Msg
    | Message ID Message.Msg
    | SendMessage String
    | ReceiveMessage String


type alias Model =
    { sender : Sender.Model Msg
    , messages : List ( ID, Message.Model )
    , nextID : ID
    }


type alias ID =
    Int


init : Model
init =
    { sender = Sender.init SendMessage
    , messages = []
    , nextID = 0
    }



-- WEBSOCKET


echoServer : String
echoServer =
    "ws://echo.websocket.org"



-- UPDATE


update : Msg -> Model -> Update.Action Msg Model msg'
update msg model =
    case msg of
        Sender msg' ->
            Update.component msg' model.sender (Sender) (\x -> { model | sender = x }) Sender.update

        Message id msg' ->
            Update.components id msg' model.messages (Message id) (\x -> { model | messages = x }) Message.update

        SendMessage message ->
            Update.cmd (WebSocket.send echoServer message)

        ReceiveMessage text ->
            let
                id =
                    model.nextID

                message =
                    Message.init text
            in
                Update.model
                    { model
                        | messages = ( id, message ) :: model.messages
                        , nextID = model.nextID + 1
                    }



-- SUBSCRIPTIONS


subscriptions : (Msg -> msg) -> Model -> Sub msg
subscriptions tag model =
    WebSocket.listen echoServer (tag << ReceiveMessage)



-- VIEW


view : (Msg -> msg) -> Model -> Html msg
view tag model =
    Html.div []
        [ Sender.view (tag << Sender) model.sender
        , Html.div [] (List.map (viewMessage tag) (List.reverse model.messages))
        ]


viewMessage : (Msg -> msg) -> ( ID, Message.Model ) -> Html msg
viewMessage tag ( id, message ) =
    Message.view (tag << Message id) message
