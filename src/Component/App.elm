module Component.App exposing (program)

{-| These functions help you define a `main` value as required by all Elm applications.

# Create a Program

Your main elm file will likely contain something like this:

    import TopLevelComponent

    main =
      Update.App.program
        { init = TopLevelComponent.init
        , view = TopLevelComponent.view
        , update = TopLevelComponent.update
        , subscriptions = TopLevelComponent.subscriptions
        }

@docs program, beginnerProgram

-}

import Html exposing (Html)
import Html.App
import Component.Update as Update


program :
    { init : model
    , update : msg -> model -> Update.Action msg model
    , view : (msg -> msg) -> model -> Html msg
    , subscriptions : (msg -> msg) -> model -> Sub msg
    }
    -> Program Never
program with =
    Html.App.program
        { init = ( with.init, Cmd.none )
        , view = with.view identity
        , update = Update.program with.update
        , subscriptions = with.subscriptions identity
        }


beginnerProgram :
    { init : model
    , update : msg -> model -> Update.Action msg model
    , view : (msg -> msg) -> model -> Html msg
    }
    -> Program Never
beginnerProgram with =
    Html.App.program
        { init = ( with.init, Cmd.none )
        , view = with.view identity
        , update = Update.program with.update
        , subscriptions = \model -> Sub.none
        }
