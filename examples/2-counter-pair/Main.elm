module Main exposing (..)

import Component.App
import CounterPair


main =
    Component.App.beginnerProgram
        { init = CounterPair.init 0 0
        , view = CounterPair.view
        , update = CounterPair.update
        }
