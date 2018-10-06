module Chatango.Util.HTTP where

import Prelude

import Affjax (get, printResponseFormatError)
import Affjax.ResponseFormat as RFormat
import Data.Bifunctor (lmap)
import Data.Either (Either(..), either)
import Data.Maybe (maybe)
import Data.Nullable (toMaybe)
import Data.Options (Options, assoc)
import Data.String (length)
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Aff (Aff, attempt, makeAff, runAff, throwError)
import Effect.Class (liftEffect)
import Effect.Console (logShow)
import Effect.Exception (Error, error)
import Foreign.Object (fromFoldable, toUnfoldable)
import Node.Encoding (Encoding(..))
import Node.HTTP.Client (RequestHeaders(RequestHeaders), RequestOptions, Response, headers, hostname, method, path, protocol, request, requestAsStream, requestFromURI, responseAsStream, responseCookies, responseHeaders)
import Node.Stream (Readable, end, onError, writeString)
import Node.URL as URL

asyncGet :: String -> Aff (Either String String)
asyncGet u = (lmap show) <$> attempt do
  response <- get RFormat.string u
  either (throwError <<< error <<< printResponseFormatError) (pure <<< identity) response.body

-- https://github.com/Thimoteus/purescript-simple-request/blob/master/src/Node/SimpleRequest.purs

foreign import responseBodyJs :: forall w. 
                                 Readable w -> 
                                 (Error -> Effect Unit) -> 
                                 (String -> Effect Unit) -> 
                                 Effect Unit

responseBody :: Response -> (Either Error String -> Effect Unit) -> Effect Unit
responseBody res handler = responseBodyJs (responseAsStream res) (handler <<< Left) (handler <<< Right)

requestEff :: Options RequestOptions -> (Either Error Response -> Effect Unit) -> Effect Unit
requestEff opts handler = do
  req <- request opts (handler <<< Right)
  end (requestAsStream req) (pure unit)

requestAff :: Options RequestOptions -> Aff Response
requestAff opts = makeAff $ requestEff opts >>> const (pure mempty)

requestFromURIEff :: forall a. String -> a -> (Response -> Effect Unit ) -> Effect Unit
requestFromURIEff uri err suc = do
  req <- requestFromURI uri suc
  end (requestAsStream req) (pure unit)

requestFromURIEff2 :: String -> (Either Error Response -> Effect Unit) -> Effect Unit
requestFromURIEff2 uri handler = do
  req <- requestFromURI uri (handler <<< Right)
  end (requestAsStream req) (pure unit)

requestFromURIAff :: String -> Aff Response
requestFromURIAff uri = makeAff $ requestFromURIEff2 uri >>> const (pure mempty)

postRequest :: String -> String -> (Either Error Response -> Effect Unit) -> Effect Unit
postRequest uri str handler = 
  let
    url = URL.parse uri
    opts =
      assoc method   "POST" <>
      assoc protocol (maybe "http:"            identity (toMaybe url.protocol)) <>
      assoc hostname (maybe "www.chatango.com" identity (toMaybe url.hostname)) <>
      assoc path     (maybe "/"                identity (toMaybe url.path))     <>
      (assoc headers $ RequestHeaders $ fromFoldable [ 
        Tuple "User-Agent"     "Mozilla/5.0 (Linux x64) node.js",
        Tuple "Connection"     "keep-alive",
        Tuple "Content-Type"   "application/x-www-form-urlencoded",
        Tuple "Content-Length" (show $ length str) ])
  in do
    req <- request opts (handler <<< Right)
    let stream = requestAsStream req
    onError stream (handler <<< Left)
    _ <- writeString stream UTF8 str (pure unit)
    end stream (pure unit)

main :: Effect Unit
main = void $ runAff (either logShow logShow) do
  res <- requestFromURIAff "http://www.google.com/"
  liftEffect <<< logShow $ (toUnfoldable $ responseHeaders res) :: Array (Tuple String String)
  liftEffect <<< logShow $ responseCookies res
  body <- makeAff $ responseBody res >>> const (pure mempty)
  pure body
