module Main where

import Prelude

import Chatango.Console (repl)
import Chatango.Room (Room, authMessage, connectRoom, generateUid)
import Effect (Effect)
import Signal (flattenArray, runSignal, unwrap, (~>))
import Signal.Channel (channel, send, subscribe)

closeOrLog :: Effect Unit -> (String -> Effect Unit) -> String -> Effect Unit
closeOrLog close _ "close" = close
closeOrLog _ log str = log str

roomCommands :: Room -> String -> Effect Unit
roomCommands _      ""      = pure unit
roomCommands room "close" = room.close
roomCommands room str     = do
  --log $ chatMessage "j7m4" str
  --WS.send socket $ chatMessage "j7m4" str
  room.send $ str <> "\r\n"

respond :: String -> String
respond "v:15:15" = authMessage "svikings" "" "" ""
respond "inited"  = "msgbg:0\r\n"
respond str       = ""

--Responder :: Group -> String -> String -> Effect
--respond "v:15:15" = WS.send socket authMsg
--respond "inited"  = WS.send socker "msgbg:0\r\n" 
--respond str       = handler str

--connectAnon :: Group ->  
--connectNamedAnon
--connectUser
main :: Effect Unit
main = do
  commands <- channel ""
  console  <- repl "\x1b[1m\x1b[35muser\x1b[0m\x1b[1m>\x1b[0m " $ \cmd -> send commands cmd
  runSignal $ subscribe commands ~> closeOrLog console.close console.log
  messages <- channel ""
  runSignal $ subscribe messages ~> console.log
  let responses = subscribe messages ~> respond
  chatango <- connectRoom "svikings" (\msg -> send messages msg)
  runSignal $ responses ~> chatango.send

