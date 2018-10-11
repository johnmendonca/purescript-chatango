module Chatango.Room where

import Prelude

import Chatango.Server (groupServer)
import Chatango.Console (repl)
import Chatango.Util.WebSocket (WebSocket, close, newWebSocket, onclose, onmessage, onopen)
import Chatango.Util.WebSocket as WS
import Data.Array (fromFoldable, catMaybes)
import Data.Char (fromCharCode)
import Data.List.Lazy (replicateM)
import Data.Options (opt, (:=))
import Data.String (joinWith)
import Data.String.CodeUnits (fromCharArray)
import Effect (Effect)
import Effect.Console (log)
import Effect.Random (randomInt)
import Effect.Timer (setInterval)
import Signal (flattenArray, runSignal, unwrap, (~>))
import Signal.Channel (channel, send, subscribe)

generateUid :: Effect String
generateUid = do
  ints <- replicateM 16 (randomInt 48 57)
  pure <<< fromCharArray <<< catMaybes $ fromCharCode <$> fromFoldable ints

socketUrl :: String -> String
socketUrl group = "ws://" <> (groupServer group) <> ".chatango.com:8080"

authMessage :: String -> String -> String -> String -> String
authMessage group uid user pass = (joinWith ":" ["bauth", group, uid, user, pass]) <> "\r\n\x00"

chatMessage :: String -> String -> String
chatMessage uid msg = (joinWith ":" ["bm", uid, "0", msg]) <> "\r\n"

socketHandler :: WebSocket -> String -> Effect Unit
socketHandler _      ""      = pure unit
socketHandler socket "close" = close socket
socketHandler socket str     = do
  --log $ chatMessage "j7m4" str
  --WS.send socket $ chatMessage "j7m4" str
  WS.send socket $ str <> "\r\n"

processMessage :: String -> Effect (Array String)
processMessage str = do
  log str
  respond str

respond :: String -> Effect (Array String)
respond "v:15:15" = do
  uid <- generateUid
  pure [ authMessage "group" uid "user" "password" ]
respond "inited"  = pure ["msgbg:0\r\n"] 
respond str       = pure []

main :: Effect Unit
main = do
  socket <- newWebSocket
              (socketUrl "group")
              []
              (opt "origin" := "http://st.chatango.com")

  onopen socket $ do
    outChan <- (channel "v\x00") 
    _ <- setInterval 90000 $ do
      send outChan "\r\n"

    inChan  <- (channel "")
    onmessage socket $ \msg -> send inChan msg

    let manualOut = subscribe outChan
        botActions = subscribe inChan ~> processMessage

    maybeResponses <- unwrap botActions

    let responses = flattenArray maybeResponses ""
        sending = (manualOut <> responses) ~> (WS.send socket)

    runSignal $ sending

    log "Opened"

    repl "\x1b[1m\x1b[35muser\x1b[0m\x1b[1m>\x1b[0m " $ socketHandler socket

  onclose socket $ log "Closed"


