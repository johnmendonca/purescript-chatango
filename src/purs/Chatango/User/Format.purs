module Chatango.User.Format where

import Prelude

import Chatango.Urls (formatUrl)
import Chatango.Util.HTTP (asyncGet)
import Control.Monad.Except (runExcept, withExcept)
import Control.Monad.Except.Trans (ExceptT(ExceptT), runExceptT)
import Data.Either (Either)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Effect (Effect)
import Effect.Aff (Aff, launchAff)
import Effect.Class (liftEffect)
import Effect.Console (logShow)
import Foreign (Foreign, F)
import Foreign.Generic (defaultOptions, genericDecode, genericDecodeJSON)

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

readFormat :: Foreign -> F Format
readFormat = genericDecode $ defaultOptions { unwrapSingleConstructors = true }

getUserFormat :: String → Aff (Either String Format)
getUserFormat = runExceptT <<< getUserFormatT

getUserFormatT :: String → ExceptT String Aff Format
getUserFormatT user = do
  url <- ExceptT $ pure $ formatUrl user
  res <- ExceptT $ asyncGet url
  ExceptT $ pure $ runExcept $ withExcept show $ genericDecodeJSON defaultOptions { unwrapSingleConstructors = true } res
 
main :: Effect Unit
main = void $ launchAff do
  fmt <- runExceptT $ getUserFormatT "rangerfrex"
  liftEffect <<< logShow $ fmt

