module Main where

import Prelude (Unit)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)

main :: ∀ t1. Eff ( console ∷ CONSOLE | t1 ) Unit
main = log "Hello"

