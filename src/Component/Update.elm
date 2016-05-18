module Update
    exposing
        ( Action
        , component
        , components
        , program
        )

{- Building blocks for writing component update functions.

   Component update functions can do a combination of:

       * Update the component's **model**,
       * Return a **command** (Cmd.Cmd msg),
       * Forward an additional **message** through the update function, or
       * Return an **event** to the parent component.

   The update function does this by returning an Update.Action created with
   functions in the module.

   # Action creation

   @docs ignore, cmd, msg, event, eventIgnored, model, modelAndCmd, modelAndMsg, modelAndEvent

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


ignore : Action msg model
ignore =
    Ignore


cmd : Cmd.Cmd msg -> Action msg model
cmd =
    cmd


msg : msg -> Action msg model
msg =
    Msg


event : msg -> Action msg model
event =
    Event


eventIgnored : msg -> Action msg model
eventIgnored =
    Ignore


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



-- CHILD COMPONENTS


component :
    msg
    -> model
    -> (msg -> msg')
    -> (model -> model')
    -> (msg -> model -> Action msg model)
    -> Action msg' model'
component msg model tag wrap step =
    Ignore


components :
    id
    -> msg
    -> List ( id, model )
    -> (msg -> msg')
    -> (List ( id, model ) -> model')
    -> (msg -> model -> Action msg model)
    -> Action msg' model'
components id msg models tag wrap step =
    Ignore



-- APPLICATION SUPPORT


program :
    (msg -> model -> Action msg model)
    -> msg
    -> model
    -> ( model, Cmd msg )
program step msg model =
    ( model, Cmd.none )
