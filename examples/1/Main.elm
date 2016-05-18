import Component.App
import Counter


main =
  Component.App.beginnerProgram
    { init = Counter.init 0
    , view = Counter.view
    , update = Counter.update
    }
