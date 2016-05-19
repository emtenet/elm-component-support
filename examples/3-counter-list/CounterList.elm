module CounterList
    exposing
        ( Msg
        , Model
        , init
        , update
        , view
        )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Component.Update as Update
import Counter


-- MODEL


type Msg
    = Insert
    | Remove
    | Counter ID Counter.Msg


type alias Model =
    { counters : List ( ID, Counter.Model )
    , nextID : ID
    }


type alias ID =
    Int


init : Model
init =
    { counters = []
    , nextID = 0
    }



-- UPDATE


update : Msg -> Model -> Update.Action Msg Model
update msg' model =
    case msg' of
        Insert ->
            let
                newCounter =
                    ( model.nextID, Counter.init 0 )

                newCounters =
                    model.counters ++ [ newCounter ]
            in
                Update.model
                    { model
                        | counters = newCounters
                        , nextID = model.nextID + 1
                    }

        Remove ->
            Update.model { model | counters = List.drop 1 model.counters }

        Counter id msg ->
            Update.components id msg model.counters (Counter id) (\x -> { model | counters = x }) Counter.update



-- VIEW


view : (Msg -> msg) -> Model -> Html msg
view tag model =
    let
        counters =
            List.map (viewCounter tag) model.counters

        remove =
            button [ onClick (tag Remove) ] [ text "Remove" ]

        insert =
            button [ onClick (tag Insert) ] [ text "Add" ]
    in
        div [] ([ remove, insert ] ++ counters)


viewCounter : (Msg -> msg) -> ( ID, Counter.Model ) -> Html msg
viewCounter tag ( id, model ) =
    Counter.view (tag << Counter id) model
