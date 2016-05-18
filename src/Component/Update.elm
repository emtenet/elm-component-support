module Component.Update
    exposing
        ( Action
        , ignore
        , cmd
        , msg
        , event
        , eventIgnored
        , model
        , modelAndCmd
        , modelAndMsg
        , modelAndEvent
        , component
        , components
        , program
        )

{-| Building blocks for writing component update functions.

Component update functions have the following type signature:

update : Msg -> Model -> Component.Update.Action Msg Model

Component update functions, on receipt of a message, can do a combination of:

    * Update the component's `model`,
    * Forward messages to a child `component` or list of `components`,
    * Return an `event` to the parent component,
    * Request a command (`cmd`) to be performed,
    * Inject an additional message (`msg`) through the update function, or
    * **ignore** the message.

These **actions** are performed by returning the appropriate `Update.Action`
from the update function.

@docs Action

# Simple actions

@docs ignore, model, cmd, msg, event, eventIgnored

# Combinations of actions

@docs modelAndCmd, modelAndMsg, modelAndEvent

# Child components

Messages addressed to components can be processed by calling `component` or
`components`, these will process any child component's actions and feed any
events back into your update function.

@docs component, components

# Application support

The following `program` function is used by `Component.App` and should not need
to be called directly.

@docs program

-}


-- ACTION


{-| Represents the actions an update function may perform.
-}
type Action msg model
    = Ignore
    | Cmd (Cmd.Cmd msg)
    | Msg msg
    | Event msg
    | Model model
    | ModelAndCmd model (Cmd.Cmd msg)
    | ModelAndMsg model msg
    | ModelAndEvent model msg



-- ACTION CREATION


{-| Used to indicate that no action is to be performed.

Useful as a placeholder until some update code is written.
-}
ignore : Action msg model
ignore =
    Ignore


{-| Request an command is performed.

    Update.cmd (WebSocket.send "ws://echo.websocket.org" "Message to be sent")
-}
cmd : Cmd.Cmd msg -> Action msg model
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
msg : msg -> Action msg model
msg =
    Msg


{-| Return an event to the parent component.

Your `Msg` union type will be divided into private component messages and
event messages returned to the parent component.

    module Button exposing (Msg, init, update, view)

    import Html
    import Html.Events
    import Component.Update as Update

    type Msg
        = Click
        | ClickEvent

    init = ()

    update msg model =
        case msg of
            Click ->
                -- start animations, check if enabled ...
                Update.event ClickEvent

            ClickEvent ->
                Update.eventIgnored
-}
event : msg -> Action msg model
event =
    Event


{-| Used to document that the message was an event intended for the parent
component, but the parent component did not process the message and passed 
it back to your component.

See above example for `event`.
-}
eventIgnored : Action msg model
eventIgnored =
    Ignore


{-| Update the model

    case msg of
        Increment
            Update.model { model | counter = model.counter + 1 }

-}
model : model -> Action msg model
model =
    Model


modelAndCmd : model -> Cmd.Cmd msg -> Action msg model
modelAndCmd =
    ModelAndCmd


modelAndMsg : model -> msg -> Action msg model
modelAndMsg =
    ModelAndMsg


modelAndEvent : model -> msg -> Action msg model
modelAndEvent =
    ModelAndEvent



-- COMPONENT


component :
    msg
    -> model
    -> (msg -> msg')
    -> (model -> model')
    -> (msg -> model -> Action msg model)
    -> Action msg' model'
component msg model tag wrap update =
    componentFold msg model False tag wrap update


componentFold :
    msg 
    -> model 
    -> Bool
    -> (msg -> msg')
    -> (model -> model') 
    -> (msg -> model -> Action msg model) 
    -> Action msg' model'
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

        Event msg' ->
            if updated then
                ModelAndMsg (wrap model) (tag msg')
            else
                Msg (tag msg')

        Model model' ->
            Model (wrap model')

        ModelAndCmd model' cmd ->
            ModelAndCmd (wrap model') (Cmd.map tag cmd)

        ModelAndMsg model' msg' ->
            componentFold msg' model' True tag wrap update

        ModelAndEvent model' msg' ->
            ModelAndMsg (wrap model') (tag msg')



-- LIST OF COMPONENTS


components :
    id
    -> msg
    -> List ( id, model )
    -> (msg -> msg')
    -> (List ( id, model ) -> model')
    -> (msg -> model -> Action msg model)
    -> Action msg' model'
components id msg models tag wrap update =
  case componentFindById id models of
    Nothing ->
      Ignore

    Just model ->
      let
        wrap' = wrap << componentReplaceById id models
      in
        componentFold msg model False tag wrap' update


componentFindById : id -> List (id, model) -> Maybe model
componentFindById id models =
  let
    find (id', _) = (id' == id)
  in
    case List.filter find models of
      [ (_, model) ] ->
        Just model
      _ ->
        Nothing


componentReplaceById : id -> List (id, model) -> model -> List (id, model)
componentReplaceById id models with =
  let
    replace model =
      if id == fst model then 
        (id, with)
      else
        model
  in
    List.map replace models


-- APPLICATION SUPPORT


program :
    (msg -> model -> Action msg model)
    -> msg
    -> model
    -> ( model, Cmd msg )
program update msg model =
  programFold msg model update


programFold :
    msg 
    -> model 
    -> (msg -> model -> Action msg model) 
    -> ( model, Cmd msg )
programFold msg model update =
  case update msg model of
    Ignore ->
      ( model, Cmd.none )

    Cmd cmd ->
      ( model, cmd )

    Msg msg' ->
      programFold msg' model update

    Event msg' ->
      -- no one to notify, ignore instead
      ( model, Cmd.none )

    Model model' ->
      ( model', Cmd.none )

    ModelAndCmd model' cmd ->
      ( model', cmd )

    ModelAndMsg model' msg' ->
      programFold msg' model' update

    ModelAndEvent model' msg' ->
      -- no one to notify, ignore instead
      ( model', Cmd.none )
