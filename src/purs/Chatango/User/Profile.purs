module Chatango.User.Profile where

import Prelude
import Chatango.Urls (profileUrl)
import Chatango.Util.Xml (childNamed, xmlVal, xmldocE)
import Chatango.Util.HTTP (asyncGet)
import Control.Monad.Aff (Aff)
import Control.Monad.Except.Trans (ExceptT(ExceptT), runExceptT)
import Data.Either (Either)
import Data.Maybe (Maybe)
import Network.HTTP.Affjax (AJAX)

newtype UserProfile = UserProfile {
  about     :: Maybe String,
  birthdate :: Maybe String,
  gender    :: Maybe String,
  location  :: Maybe String
}

instance showUserProfile :: Show UserProfile where
  show (UserProfile r) = "UserProfile { about: "     <> show r.about     <> ", "
                                   <> " birthdate: " <> show r.birthdate <> ", "
                                   <> " gender: "    <> show r.gender    <> ", "
                                   <> " location: "  <> show r.location  <> " }"

getUserProfile :: ∀ t. String → Aff ( ajax ∷ AJAX | t ) (Either String UserProfile)
getUserProfile = runExceptT <<< getUserProfileT

getUserProfileT :: ∀ t23. String → ExceptT String (Aff ( ajax ∷ AJAX | t23 ) ) UserProfile
getUserProfileT user = do
  url  <- ExceptT $ pure $ profileUrl user
  res  <- ExceptT $ asyncGet url
  xml  <- ExceptT $ pure $ xmldocE res
  pure $ UserProfile {
    about:     xmlVal <$> childNamed xml "body",
    birthdate: xmlVal <$> childNamed xml "b",
    gender:    xmlVal <$> childNamed xml "s",
    location:  xmlVal <$> childNamed xml "l"
  }

