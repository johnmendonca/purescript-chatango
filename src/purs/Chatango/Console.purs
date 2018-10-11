module Chatango.Console (repl) where

import Prelude

import Effect (Effect)
import Effect.Console (log)
import Node.Process (exit, stdout)
import Node.ReadLine (Interface, clearLine, close, createConsoleInterface, cursorToX, noCompletion, onClose, prompt, promptPreserve, setLineHandler, setPrompt)

type Console =
  { log       :: String -> Effect Unit
  , setPrompt :: String -> Effect Unit
  , close     :: Effect Unit
  }

repl :: forall a. Discard a => String -> (String -> Effect a) -> Effect Console
repl prmt handler = do
  interface <- createConsoleInterface noCompletion
  onClose interface $ do
     log "\r\nGoodbye"
     exit 0
  setPrompt prmt 0 interface
  setLineHandler interface (rep_loop interface handler)
  prompt interface
  pure { log: logger interface, setPrompt: \x -> setPrompt x 0 interface, close: close interface }

rep_loop :: forall a b. Discard b => Interface -> (a -> Effect b) -> a -> Effect Unit
rep_loop i handler s = do
  prompt i
  handler s
  pure unit

logger :: Interface -> String -> Effect Unit
logger _ ""  = pure unit
logger i msg = do
  clearLine stdout 0
  cursorToX stdout 0
  log msg
  promptPreserve i

