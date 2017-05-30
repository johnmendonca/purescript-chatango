module Chatango.User.Format where

import Prelude
import Chatango.Urls (formatUrl)
import Chatango.Util.HTTP (asyncGet)
import Control.Monad.Aff (Aff, launchAff)
import Control.Monad.Aff.Console (logShow)
import Control.Monad.Except (runExcept, withExcept)
import Control.Monad.Except.Trans (ExceptT(ExceptT), runExceptT)
import Data.Either (Either)
import Data.Foreign.Class (class IsForeign, readJSON, readProp)
import Data.Foreign.Generic (defaultOptions, readGeneric)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Network.HTTP.Affjax (AJAX)

newtype Format = Format {
  fontFamily    :: String,
  fontSize      :: String,
  bold          :: Boolean,
  stylesOn      :: Boolean,
  usebackground :: String,
  italics       :: Boolean,
  textColor     :: String,
  underline     :: Boolean,
  nameColor     :: String
}

derive instance repFormat :: Generic Format _

instance formatShow :: Show Format where
  show = genericShow

instance formatIsForeign :: IsForeign Format where
  read = readGeneric $ defaultOptions { unwrapSingleConstructors = true }

getUserFormat :: ∀ t. String → Aff ( ajax ∷ AJAX | t ) (Either String Format)
getUserFormat = runExceptT <<< getUserFormatT

getUserFormatT :: ∀ t23. String → ExceptT String (Aff ( ajax ∷ AJAX | t23 ) ) Format
getUserFormatT user = do
  url <- ExceptT $ pure $ formatUrl user
  res <- ExceptT $ asyncGet url
  ExceptT $ pure $ runExcept $ withExcept show $ readJSON res
 
main = void $ launchAff do
  fmt <- runExceptT $ getUserFormatT "rangerfrex"
  logShow fmt

