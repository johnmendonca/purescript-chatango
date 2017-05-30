module Chatango.User.FormatVerbose where

import Prelude
import Chatango.Urls (formatUrl)
import Chatango.Util.HTTP (asyncGet)
import Control.Monad.Aff (Aff)
import Control.Monad.Except (runExcept, withExcept)
import Control.Monad.Except.Trans (ExceptT(ExceptT), runExceptT)
import Data.Either (Either)
import Data.Foreign.Class (class IsForeign, readJSON, readProp)
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

instance formatShow :: Show Format where
  show (Format r) = "Format { fontFamily: "    <>      r.fontFamily
                        <> ", fontSize: "      <>      r.fontSize
                        <> ", bold: "          <> show r.bold
                        <> ", stylesOn: "      <> show r.stylesOn
                        <> ", usebackground: " <>      r.usebackground
                        <> ", italics: "       <> show r.italics
                        <> ", textColor: "     <>      r.textColor
                        <> ", underline: "     <> show r.underline
                        <> ", nameColor: "     <>      r.nameColor <> " }"

instance formatIsForeign :: IsForeign Format where
  read value = do
    fontFamily    <- readProp "fontFamily" value
    fontSize      <- readProp "fontSize" value
    bold          <- readProp "bold" value
    stylesOn      <- readProp "stylesOn" value
    usebackground <- readProp "usebackground" value
    italics       <- readProp "italics" value
    textColor     <- readProp "textColor" value
    underline     <- readProp "underline" value
    nameColor     <- readProp "nameColor" value
    pure $ Format {
      fontFamily:     fontFamily,
      fontSize:       fontSize,
      bold:           bold,
      stylesOn:       stylesOn,
      usebackground:  usebackground,
      italics:        italics,
      textColor:      textColor,
      underline:      underline,
      nameColor:      nameColor
    }

getUserFormat :: ∀ t. String → Aff ( ajax ∷ AJAX | t ) (Either String Format)
getUserFormat = runExceptT <<< getUserFormatT

getUserFormatT :: ∀ t23. String → ExceptT String (Aff ( ajax ∷ AJAX | t23 ) ) Format
getUserFormatT user = do
  url <- ExceptT $ pure $ formatUrl user
  res <- ExceptT $ asyncGet url
  ExceptT $ pure $ runExcept $ withExcept show $ readJSON res
 
