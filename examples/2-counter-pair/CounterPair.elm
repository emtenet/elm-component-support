module CounterPair
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
    = Reset
    | Top Counter.Msg
    | Bottom Counter.Msg


type alias Model =
    { top : Counter.Model
    , bottom : Counter.Model
    }


init : Int -> Int -> Model
init top bottom =
    { top = Counter.init top
    , bottom = Counter.init bottom
    }



-- UPDATE


update : Msg -> Model -> Update.Action Msg Model
update msg' model =
    case msg' of
        Reset ->
            Update.model (init 0 0)

        Top msg ->
            Update.component msg model.top (Top) (\x -> { model | top = x }) Counter.update

        Bottom msg ->
            Update.component msg model.bottom (Bottom) (\x -> { model | bottom = x }) Counter.update



-- VIEW


view : (Msg -> msg) -> Model -> Html msg
view tag model =
    div []
        [ Counter.view (tag << Top) model.top
        , Counter.view (tag << Bottom) model.bottom
        , button [ onClick (tag Reset) ] [ text "RESET" ]
        ]
