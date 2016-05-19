# elm-component-support

> Support for building applications from Elm components

This Elm package is an exploration of how components interact with each
other and how to compose components from other components.

Read about my [exploration](https://github.com/emtenet/elm-component-support/blob/master/docs/index.md)

## Component signature

Each component has the following type signature:

```elm
module X
    exposing
        ( Msg (PublicEvent1, PublicEvent2, ...)
        , Model
        , init
        , update
        , view
        , subscriptions
        )

type Msg
    = PrivateMsg1
    | PrivateMsg2
    | ...
    | PublicEvent1
    | PublicEvent2
    | ...

type alias Model = 

update : Msg -> Model -> Update.Action Msg Model

view : (Msg -> msg) -> Model -> Html msg

subscriptions : (Msg -> msg) -> Model -> Sub msg
```

## Run the examples

This repo contains examples showing usage of this Elm package.
Download this repo with:

```bash
git clone https://github.com/emtenet/elm-component-support.git
```

Run an example by changing to the example directory and running `elm-reactor`:

```bash
cd elm-component-support/examples/1-counter
elm-reactor
```

Now go to [http://localhost:8000/](http://localhost:8000/) and click on `Main.elm`.