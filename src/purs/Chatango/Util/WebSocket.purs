module Chatango.Util.WebSocket 
  ( WebSocket
  , newWebSocket
  , onopen
  , onclose
  , onmessage
  , send
  , close
  ) where

import Effect (Effect)
import Foreign (Foreign)
import Data.Options (Options, options)
import Prelude (Unit)

foreign import data WebSocket :: Type

type URL       = String
type EventName = String
type Message   = String
type Protocol  = String

foreign import newWebSocketImpl :: URL -> Array Protocol -> Foreign -> Effect WebSocket

newWebSocket :: String -> Array String -> Options WebSocket -> Effect WebSocket
newWebSocket url protocols opts = newWebSocketImpl url protocols (options opts)

foreign import addNullHandler :: forall a. WebSocket -> EventName -> Effect a -> Effect Unit

onopen :: forall a. WebSocket -> Effect a -> Effect Unit 
onopen socket action = addNullHandler socket "open" action

onclose :: forall a. WebSocket -> Effect a -> Effect Unit
onclose socket action = addNullHandler socket "close" action

foreign import addStringHandler :: forall a. WebSocket -> EventName -> (String -> Effect a) -> Effect Unit

onmessage :: forall a. WebSocket -> (String -> Effect a) -> Effect Unit
onmessage socket handler = addStringHandler socket "message" handler

foreign import send :: WebSocket -> String -> Effect Unit

foreign import close :: WebSocket -> Effect Unit

