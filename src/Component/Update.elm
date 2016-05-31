module Component.Update
    exposing
        ( Action
        , ignore
        , cmd
        , msg
        , model
        , modelAndReturn
        , return
        , returnMaybe
        , component
        , components
        , program
        )

{-| Building blocks for writing component update functions.

# Update functions

Component update functions have the following type signature:

    import Component.Update as Update

    update : Msg -> Model -> Update.Action Msg Model msg'

NOTE: The use of `msg'` (message prime) to represent the parent component's
message type in comparison with this component's general message type `msg`.
This prime notation is also used to represent the parent component's model type `model'`.

# Update actions

Component update functions, on receipt of a message, can do a combination of:

    * Update the component's `model`,
    * Forward messages to a child `component` or list of `components`,
    * Return a message to the parent component,
    * Request a command (`cmd`) to be executed,
    * Inject an additional message (`msg`) through the update function, or
    * **ignore** the message.

@docs Action

# Simple actions

@docs ignore, model, return, returnMaybe, cmd, msg

# Combinations of actions

@docs modelAndReturn

# Child components

Messages addressed to components can be processed by calling `component` or
`components`, these will process any child component's actions and feed any
returned messages back into your update function.

@docs component, components

# Application support

@docs program

-}

-- ACTION


{-| Represents the actions an update function may perform.
-}
type Action msg model msg'
    = Ignore
    | Cmd (Cmd.Cmd msg)
    | Msg msg
    | Model model
    | ModelAndCmd model (Cmd.Cmd msg)
    | ModelAndMsg model msg
    | ModelAndReturn model msg'
    | Return msg'



-- ACTION CREATION


{-| Used to indicate that no action is to be performed.

Useful as a placeholder until some update code is written.
-}
ignore : Action msg model msg'
ignore =
    Ignore


{-| Request an command is performed.

    Update.cmd (WebSocket.send "ws://echo.websocket.org" "Message to be sent")
-}
cmd : Cmd.Cmd msg -> Action msg model msg'
cmd =
    Cmd


{-| Inject a message back into the update function.

Useful for renaming common events that come from multiple child components.

    case msg of
        SearchButton Button.ClickEvent ->
            Update.msg StartSearch

        SearchTextBox TextBox.EnterPressedEvent ->
            Update.msg StartSearch

        StartSearch ->
            ...

        ...
-}
msg : msg -> Action msg model msg'
msg =
    Msg


{-| Update the model

    case msg of
        Increment
            Update.model { model | counter = model.counter + 1 }

-}
model : model -> Action msg model msg'
model =
    Model


{-| Update the model and return a message to the parent component.

See `model` and `return` for usage suggestions.
-}
modelAndReturn : model -> msg' -> Action msg model msg'
modelAndReturn =
    ModelAndReturn


{-| Return a message to the parent component.

    Html.input [ Html.Events.onKeyPress (tag << KeyPress) ] []

    case msg of
        KeyPress key ->
            if key == 13 then
                Update.return EnterPressed
            else
                Update.ignore

-}
return : msg' -> Action msg model msg'
return =
    Return


{-|
-}
returnMaybe : Maybe msg' -> Action msg model msg'
returnMaybe maybe =
    case maybe of
        Just msg ->
            Return msg

        Nothing ->
            Ignore



-- COMPONENT


{-| Forward messages to a child component.

    import Counter
    import Component.Update as Update

    type Msg
        = Top Counter.Msg
        | Bottom Counter.Msg

    type alias Model =
        { top : Counter.Model
        , bottom : Counter.Model
        }

    update : Msg -> Model -> Update.Action Msg Model msg'
    update msg' model =
        case msg' of
            Top msg ->
                Update.component msg model.top (Top) (\x -> { model | top = x }) Counter.update

            Bottom msg ->
                Update.component msg model.bottom (Bottom) (\x -> { model | bottom = x }) Counter.update
-}
component :
    msg
    -> model
    -> (msg -> msg')
    -> (model -> model')
    -> (msg -> model -> Action msg model msg')
    -> Action msg' model' msg''
component msg model tag wrap update =
    componentFold msg model False tag wrap update


componentFold :
    msg
    -> model
    -> Bool
    -> (msg -> msg')
    -> (model -> model')
    -> (msg -> model -> Action msg model msg')
    -> Action msg' model' msg''
componentFold msg model updated tag wrap update =
    case update msg model of
        Ignore ->
            if updated then
                Model (wrap model)
            else
                Ignore

        Cmd cmd ->
            if updated then
                ModelAndCmd (wrap model) (Cmd.map tag cmd)
            else
                Cmd (Cmd.map tag cmd)

        Msg msg' ->
            componentFold msg' model updated tag wrap update

        Model model' ->
            Model (wrap model')

        ModelAndCmd model' cmd ->
            ModelAndCmd (wrap model') (Cmd.map tag cmd)

        ModelAndMsg model' msg' ->
            componentFold msg' model' True tag wrap update

        ModelAndReturn model' msg' ->
            ModelAndMsg (wrap model') msg'

        Return msg' ->
            if updated then
                ModelAndMsg (wrap model) msg'
            else
                Msg msg'



-- LIST OF COMPONENTS


{-| Forward messages to a list of child components.

    import Counter
    import Component.Update as Update

    type Msg = Counter Int Counter.Msg

    type alias Model =
        { counters : List ( Int, Counter.Model )
        }

    update : Msg -> Model -> Update.Action Msg Model msg'
    update msg' model =
        case msg' of
            Counter id msg ->
                Update.components id msg model.counters (Counter id) (\x -> { model | counters = x }) Counter.update
-}
components :
    id
    -> msg
    -> List ( id, model )
    -> (msg -> msg')
    -> (List ( id, model ) -> model')
    -> (msg -> model -> Action msg model msg')
    -> Action msg' model' msg''
components id msg models tag wrap update =
    case componentFindById id models of
        Nothing ->
            Ignore

        Just model ->
            let
                wrap' =
                    wrap << componentReplaceById id models
            in
                componentFold msg model False tag wrap' update


componentFindById : id -> List ( id, model ) -> Maybe model
componentFindById id models =
    let
        find ( id', _ ) =
            (id' == id)
    in
        case List.filter find models of
            [ ( _, model ) ] ->
                Just model

            _ ->
                Nothing


componentReplaceById : id -> List ( id, model ) -> model -> List ( id, model )
componentReplaceById id models with =
    let
        replace model =
            if id == fst model then
                ( id, with )
            else
                model
    in
        List.map replace models



-- APPLICATION SUPPORT


{-| Utility function used by `Component.App.program` to convert a top level
component update function to one suitable for `Html.App.program`.
-}
program :
    (msg -> model -> Action msg model Never)
    -> msg
    -> model
    -> ( model, Cmd msg )
program update msg model =
    case update msg model of
        Ignore ->
            ( model, Cmd.none )

        Cmd cmd ->
            ( model, cmd )

        Msg msg' ->
            program update msg' model

        Model model' ->
            ( model', Cmd.none )

        ModelAndCmd model' cmd ->
            ( model', cmd )

        ModelAndMsg model' msg' ->
            program update msg' model'

        ModelAndReturn model' msg' ->
            -- no one to notify, ignore instead
            ( model', Cmd.none )

        Return msg' ->
            -- no one to return to, ignore instead
            ( model, Cmd.none )
