module Chatango.Room where

import Prelude

import Chatango.Server (groupServer)
import Chatango.Util.Console (repl)
import Chatango.Util.WebSocket (WebSocket, close, newWebSocket, onclose, onmessage, onopen, send)
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

generateUid :: Effect String
generateUid = do
  ints <- replicateM 16 (randomInt 48 57)
  pure <<< fromCharArray <<< catMaybes $ fromCharCode <$> fromFoldable ints

authMessage :: String -> String -> String -> String -> String
authMessage group uid user pass = (joinWith ":" ["bauth", group, uid, user, pass]) <> "\r\n\x00"
chatMessage :: String -> String -> String
chatMessage uid msg = (joinWith ":" ["bm", uid, "o", msg]) <> "\r\n"

socketHandler :: WebSocket -> String -> Effect Unit
socketHandler _      ""      = pure unit
socketHandler socket "close" = close socket
socketHandler socket str     = do
  log $ chatMessage "j7m4" str
  send socket $ chatMessage "j7m4" str

main :: Effect Unit
main = do
  let socketUrl = "ws://" <> (groupServer "group") <> ".chatango.com:8080"
      opts      = opt "origin" := "http://st.chatango.com"
  socket <- newWebSocket socketUrl [] opts 

  uid <- generateUid
  onopen socket $ do
    send socket "v\x00"
    send socket $ authMessage "group" uid "user" "password"
    send socket "msgbg:0\r\n"
    _ <- setInterval 90000 $ do
      send socket "\r\n"
      log "bump"
    log "Opened"

  onclose socket $ log "Closed"
  onmessage socket $ \msg -> log msg

  repl $ socketHandler socket

