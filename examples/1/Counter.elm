module Counter exposing
  ( Model
  , init
  , Msg
  , update
  , view
  )


import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Component.Update as Update


-- MODEL


type Msg
  = Increment
  | Decrement


type alias Model 
  = Int


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
    , div [ countStyle ] [ Html.text (toString model) ]
    , button [ onClick (tag Increment) ] [ text "+" ]
    ]


countStyle : Html.Attribute msg
countStyle =
  style
    [ ("font-size", "20px")
    , ("font-family", "monospace")
    , ("display", "inline-block")
    , ("width", "50px")
    , ("text-align", "center")
    ]
