module Chatango.Room where

import Prelude
import Chatango.Util.WebSocket
import Chatango.Util.Console
import Chatango.Server (groupServer)
import Control.Monad.Eff.Console (log)
import Control.Monad.Eff.Random (randomInt)
import Control.Monad.Eff.Timer (setInterval)
import Data.Array (fromFoldable)
import Data.Char (fromCharCode)
import Data.List.Lazy (replicateM)
import Data.Options (opt, (:=))
import Data.String (fromCharArray, joinWith)

generateUid = do
  ints <- replicateM 16 (randomInt 48 57)
  pure $ fromCharArray $ fromCharCode <$> fromFoldable ints

authMessage group uid user pass = (joinWith ":" ["bauth", group, uid, user, pass]) <> "\r\n\x00"
chatMessage uid msg = (joinWith ":" ["bm", uid, "o", msg]) <> "\r\n"

socketHandler _      ""      = pure unit
socketHandler socket "close" = close socket
socketHandler socket str     = do
  log $ chatMessage "j7m4" str
  send socket $ chatMessage "j7m4" str

main = do
  let socketUrl = "ws://" <> (groupServer "chatroom") <> ".chatango.com:8080"
      opts      = opt "origin" := "http://st.chatango.com"
  socket <- newWebSocket socketUrl [] opts 

  uid <- generateUid
  onopen socket $ do
    send socket "v\x00"
    send socket $ authMessage "chatroom" uid "username" "password"
    send socket "msgbg:0\r\n"
    setInterval 90000 $ do
      send socket "\r\n"
      log "bump"
    log "Opened"

  onclose socket $ log "Closed"
  onmessage socket $ \msg -> log msg

  repl $ socketHandler socket

