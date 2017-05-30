module Chatango.Util.HTTP where

import Prelude
import Control.Monad.Eff.Console as EfC
import Node.URL as URL
import Control.Monad.Aff (Aff, attempt, launchAff, makeAff, runAff)
import Control.Monad.Aff.Console (CONSOLE, logShow)
import Control.Monad.Aff.Unsafe (unsafeCoerceAff)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE)
import Control.Monad.Eff.Exception (EXCEPTION, Error)
import Data.Bifunctor (lmap)
import Data.Either (Either)
import Data.Maybe (maybe)
import Data.Nullable (toMaybe)
import Data.Options (Options, assoc)
import Data.StrMap (fromFoldable, toList)
import Data.String (length)
import Data.Tuple (Tuple(..))
import Network.HTTP.Affjax (AJAX, get)
import Node.Encoding (Encoding(..))
import Node.HTTP (HTTP)
import Node.HTTP.Client (RequestHeaders(RequestHeaders), RequestOptions, Response, headers, hostname, method, path, protocol, request, requestAsStream, requestFromURI, responseAsStream, responseCookies, responseHeaders)
import Node.Stream (Readable, end, onError, writeString)

asyncGet :: ∀ t. 
            String → 
            Aff ( ajax ∷ AJAX | t ) (Either String String)
asyncGet u = (lmap show) <$> attempt do
  response <- get u
  pure response.response

-- https://github.com/Thimoteus/purescript-simple-request/blob/master/src/Node/SimpleRequest.purs

foreign import responseBodyJs :: forall w e. 
                                 Readable w e -> 
                                 (Error -> Eff e Unit) -> 
                                 (String -> Eff e Unit) -> 
                                 Eff e Unit

responseBody res err suc = responseBodyJs (responseAsStream res) err suc

requestEff :: ∀ eff. 
              Options RequestOptions → 
              (Error → Eff ( http ∷ HTTP | eff ) Unit ) → 
              (Response → Eff ( http ∷ HTTP | eff ) Unit ) → 
              Eff ( http ∷ HTTP | eff ) Unit
requestEff opts err suc = do
  req <- request opts suc
  end (requestAsStream req) (pure unit)

requestAff :: ∀ eff. 
              Options RequestOptions → 
              Aff ( http ∷ HTTP | eff ) Response
requestAff opts = makeAff $ requestEff opts

requestFromURIEff :: ∀ t2 t7. 
                     String → 
                     t2 → 
                     (Response → Eff ( http ∷ HTTP | t7 ) Unit ) → 
                     Eff ( http ∷ HTTP | t7 ) Unit
requestFromURIEff uri err suc = do
  req <- requestFromURI uri suc
  end (requestAsStream req) (pure unit)

requestFromURIAff :: ∀ t16. 
                     String → 
                     Aff ( http ∷ HTTP | t16 ) Response
requestFromURIAff uri = makeAff $ requestFromURIEff uri

postRequest :: ∀ t46. 
               String → String → 
               (Error → Eff ( http ∷ HTTP | t46 ) Unit ) → 
               (Response → Eff ( http ∷ HTTP | t46 ) Unit ) → 
               Eff ( http ∷ HTTP | t46 ) Unit
postRequest uri str err suc = 
  let
    url = URL.parse uri
    opts =
      assoc method   "POST" <>
      assoc protocol (maybe "http:"            id (toMaybe url.protocol)) <>
      assoc hostname (maybe "www.chatango.com" id (toMaybe url.hostname)) <>
      assoc path     (maybe "/"                id (toMaybe url.path))     <>
      (assoc headers $ RequestHeaders $ fromFoldable [ 
        Tuple "User-Agent"     "Mozilla/5.0 (Linux x64) node.js",
        Tuple "Connection"     "keep-alive",
        Tuple "Content-Type"   "application/x-www-form-urlencoded",
        Tuple "Content-Length" (show $ length str) ])
  in do
    req <- request opts suc
    let stream = requestAsStream req
    onError stream err
    writeString stream UTF8 str (pure unit)
    end stream (pure unit)

main :: ∀ t44. Eff ( err ∷ EXCEPTION , ajax ∷ AJAX , console ∷ CONSOLE, http :: HTTP | t44 ) Unit
main = void $ runAff EfC.logShow EfC.logShow do
  res <- requestFromURIAff "http://www.google.com/"
  logShow $ toList $ responseHeaders res
  logShow $ responseCookies res
  body <- makeAff $ responseBody res
  pure body
