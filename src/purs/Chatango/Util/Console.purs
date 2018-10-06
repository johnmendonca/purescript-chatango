module Chatango.Util.Console where

import Prelude
import Effect (Effect) 

import Node.ReadLine (Interface, createConsoleInterface, noCompletion, setLineHandler, setPrompt, prompt)

rep_loop :: forall t3 t4. Discard t4 => Interface -> (t3 -> Effect t4) -> t3 -> Effect Unit
rep_loop i handler s = do
  handler s
  prompt i

repl :: forall t15. Discard t15 => (String -> Effect t15) -> Effect Unit
repl handler = do
  interface <- createConsoleInterface noCompletion
  setPrompt "user> " 0 interface
  setLineHandler interface (rep_loop interface handler)
  prompt interface

