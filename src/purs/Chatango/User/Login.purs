module Chatango.User.Login where

import Prelude
import Chatango.Util.HTTP (postRequest, responseBody)
import Control.Monad.Aff (launchAff, makeAff)
import Control.Monad.Aff.Console (log, logShow)
import Control.Monad.Aff.Unsafe (unsafeCoerceAff)
import Data.FormURLEncoded (FormURLEncoded, encode, fromArray)
import Data.Maybe (Maybe(..))
import Data.StrMap (toList)
import Data.Tuple (Tuple(..))
import Network.HTTP.Affjax (post)
import Node.HTTP.Client (responseCookies, responseHeaders)

loginParams :: FormURLEncoded
loginParams = fromArray [
  Tuple "user_id"     (Just "username"),
  Tuple "password"    (Just "password"),
  Tuple "checkerrors" (Just "yes"),
  Tuple "storecookie" (Just "on")
]

main = void $ launchAff do
  res <- post "http://chatango.com/login" loginParams
  logShow res.status
  logShow res.headers
  log res.response

main2 = void $ launchAff $ unsafeCoerceAff do
  res  <- makeAff $ postRequest "http://chatango.com/login" (encode loginParams)
  logShow $ toList $ responseHeaders res
  logShow $ responseCookies res
  body <- makeAff $ responseBody res
  logShow body

