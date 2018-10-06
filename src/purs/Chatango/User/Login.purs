module Chatango.User.Login where

import Prelude

import Affjax (post, printResponseFormatError)
import Affjax.RequestBody as RBody
import Affjax.ResponseFormat as RFormat
import Chatango.Util.HTTP (postRequest, responseBody)
import Data.Either (either)
import Data.FormURLEncoded (FormURLEncoded, encode, fromArray)
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Aff (launchAff, makeAff)
import Effect.Class (liftEffect)
import Effect.Console (log, logShow)
import Foreign.Object (toUnfoldable)
import Node.HTTP.Client (responseCookies, responseHeaders)

loginParams :: FormURLEncoded
loginParams = fromArray [
  Tuple "user_id"     (Just "username"),
  Tuple "password"    (Just "password"),
  Tuple "checkerrors" (Just "yes"),
  Tuple "storecookie" (Just "on")
]

main :: Effect Unit
main = void $ launchAff do
  res <- post RFormat.string "http://chatango.com/login" (RBody.FormURLEncoded loginParams)
  liftEffect <<< logShow $ res.status
  liftEffect <<< logShow $ res.headers
  liftEffect <<< log     $ either printResponseFormatError identity res.body

main2 :: Effect Unit
main2 = void $ launchAff do
  res  <- makeAff $ postRequest "http://chatango.com/login" (encode loginParams) >>> const (pure mempty)
  liftEffect <<< logShow $ ((toUnfoldable $ responseHeaders res) :: Array (Tuple String String))
  liftEffect <<< logShow $ responseCookies res
  body <- makeAff $ responseBody res >>> const (pure mempty)
  liftEffect <<< logShow $ body

