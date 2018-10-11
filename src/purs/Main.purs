module Main where

import Prelude

import Chatango.Console (repl)
import Effect (Effect)
import Signal (runSignal, (~>))
import Signal.Channel (channel, send, subscribe)
import Signal.Time (delay)

closeOrLog :: Effect Unit -> (String -> Effect Unit) -> String -> Effect Unit
closeOrLog close _ "close" = close
closeOrLog _ log str = log str

main :: Effect Unit
main = do
  commands <- channel ""
  console <- repl "\x1b[1m\x1b[35muser\x1b[0m\x1b[1m>\x1b[0m " $ \cmd -> send commands cmd
  runSignal $ delay 650.0 (subscribe commands) ~> closeOrLog console.close console.log

