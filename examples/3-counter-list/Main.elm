module Main exposing (..)

import Component.App
import CounterList


main =
    Component.App.beginnerProgram
        { init = CounterList.init
        , view = CounterList.view
        , update = CounterList.update
        }
