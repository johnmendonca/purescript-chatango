module Chatango.Util.Console where

import Prelude
import Control.Monad.Eff (Eff) 
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Eff.Exception (EXCEPTION)

import Node.ReadLine (READLINE, Interface, createConsoleInterface, noCompletion, setLineHandler, setPrompt, prompt)

--rep_loop :: forall e e2. 
  --          Interface -> 
    --        (String -> Eff e2 Unit) ->
      --      String -> 
        --    Eff (console :: CONSOLE, readline :: READLINE | e) Unit
--rep_loop :: ∀ t3 t6 t8. Interface → (t3 → Eff ( readline ∷ READLINE | t8 ) t6 ) → t3 → Eff ( readline ∷ READLINE | t8 ) Unit
rep_loop i handler s = do
  handler s
  prompt i

--repl :: forall e e2. 
  --      (String -> Eff e2 Unit) -> 
    --    Eff (console :: CONSOLE, readline :: READLINE, err :: EXCEPTION | e) Unit
--repl :: ∀ t14 t26. (String → Eff ( readline ∷ READLINE , console ∷ CONSOLE , err ∷ EXCEPTION | t14 ) t26 ) → Eff ( readline ∷ READLINE , console ∷ CONSOLE , err ∷ EXCEPTION | t14 ) Unit
repl handler = do
  interface <- createConsoleInterface noCompletion
  setPrompt "user> " 0 interface
  setLineHandler interface (rep_loop interface handler)
  prompt interface

