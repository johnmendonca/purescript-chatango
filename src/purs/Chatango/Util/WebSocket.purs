module Chatango.Util.WebSocket 
  ( WebSocket
  , WEBSOCKET
  , newWebSocket
  , onopen
  , onclose
  , onmessage
  , send
  , close
  ) where

import Control.Monad.Eff (Eff)
import Data.Foreign (Foreign)
import Data.Options (Options, options)
import Prelude (Unit)

foreign import data WebSocket :: *

foreign import data WEBSOCKET :: !

type URL       = String
type EventName = String
type Message   = String
type Protocol  = String

foreign import newWebSocketImpl :: ∀ eff. 
                                   URL -> 
                                   Array Protocol -> 
                                   Foreign -> 
                                   Eff ( ws :: WEBSOCKET | eff ) WebSocket

newWebSocket :: ∀ eff. 
                String → 
                Array String → 
                Options WebSocket → 
                Eff ( ws ∷ WEBSOCKET | eff ) WebSocket
newWebSocket url protocols opts = newWebSocketImpl url protocols (options opts)

foreign import addNullHandler :: ∀ eff eff2 a. 
                                 WebSocket → 
                                 EventName → 
                                 Eff eff a → Eff ( ws ∷ WEBSOCKET | eff2 ) WebSocket

onopen :: ∀ eff eff2 a. 
          WebSocket → 
          Eff eff a → 
          Eff ( ws ∷ WEBSOCKET | eff2 ) WebSocket
onopen socket action = addNullHandler socket "open" action

onclose :: ∀ eff eff2 a. 
           WebSocket → 
           Eff eff a → 
           Eff ( ws ∷ WEBSOCKET | eff2 ) WebSocket
onclose socket action = addNullHandler socket "close" action

foreign import addStringHandler :: ∀ eff eff2 a. 
                                   WebSocket → 
                                   EventName → 
                                   (String → Eff eff a) → 
                                   Eff ( ws ∷ WEBSOCKET | eff2 ) WebSocket

onmessage :: ∀ t5 t6 eff. 
             WebSocket → 
             (String → Eff t6 t5) → 
             Eff ( ws ∷ WEBSOCKET | eff ) WebSocket
onmessage socket handler = addStringHandler socket "message" handler

foreign import send :: ∀ eff. 
                       WebSocket → 
                       String → 
                       Eff ( ws :: WEBSOCKET | eff ) Unit

foreign import close :: ∀ eff. 
                        WebSocket → 
                        Eff ( ws :: WEBSOCKET | eff ) Unit

