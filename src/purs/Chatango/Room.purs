module Chatango.Room where

import Prelude

import Chatango.Util.WebSocket as WS
import Data.Array (fromFoldable, catMaybes)
import Data.Char (fromCharCode)
import Data.Either (Either(..))
import Data.List.Lazy (replicateM)
import Data.Options (opt, (:=))
import Data.String (joinWith, null)
import Data.String.CodeUnits (fromCharArray)
import Effect (Effect)
import Effect.Aff (Aff, makeAff)
import Effect.Exception (Error)
import Effect.Random (randomInt)
import Effect.Timer (setInterval)

type Group = String

type Room =
  { group :: Group
  , send :: String -> Effect Unit
  , close :: Effect Unit
  }

foreign import groupServer :: Group -> String

generateUid :: Effect String
generateUid = do
  ints <- replicateM 16 (randomInt 48 57)
  pure <<< fromCharArray <<< catMaybes $ fromCharCode <$> fromFoldable ints

socketUrl :: Group -> String
socketUrl group = "ws://" <> (groupServer group) <> ".chatango.com:8080"

authMessage :: Group -> String -> String -> String -> String
authMessage group uid user pass = (joinWith ":" ["bauth", group, uid, user, pass]) <> "\r\n\x00"

chatMessage :: String -> String -> String
chatMessage uid msg = (joinWith ":" ["bm", uid, "0", msg]) <> "\r\n"

connectRoom :: Group -> (String -> Effect Unit) -> Effect Room
connectRoom group handler = do
  socket <- WS.newWebSocket (socketUrl group) [] (opt "origin" := "http://st.chatango.com")
  WS.onopen socket $ do
    WS.onmessage socket handler
    _ <- setInterval 90000 $ do
      WS.send socket "\r\n"
    WS.send socket "v\x00"

  pure { group: group
       , send: \str -> if (null str) then pure unit else WS.send socket str
       , close: WS.close socket
       }

connectRoomEff :: Group -> (String -> Effect Unit) -> (Either Error Room -> Effect Unit) -> Effect Unit
connectRoomEff group msgHandler responseHandler = do
  socket <- WS.newWebSocket (socketUrl group) [] (opt "origin" := "http://st.chatango.com")
  WS.onopen socket $ do
    WS.onmessage socket msgHandler
    _ <- setInterval 90000 $ do
      WS.send socket "\r\n"
    responseHandler <<< Right $ { group: group, send: WS.send socket, close: WS.close socket }

connectRoomAff :: String -> (String -> Effect Unit) -> Aff Room
connectRoomAff group msgHandler = makeAff $ connectRoomEff group msgHandler >>> const (pure mempty)

