module Chatango.Util.Xml where

import Prelude

import Control.Monad.Except (runExcept, withExcept)
import Data.Either (Either, either)
import Data.Maybe (Maybe(..))
import Foreign (F, Foreign, ForeignError(..), fail, readString, readUndefined)
import Foreign.Index ((!))

newtype XmlElement = XmlElement {
  value :: Foreign,
  name  :: String,
  val   :: String
}

instance xmlShow :: Show XmlElement where
  show (XmlElement r) = "xml { name: " <> r.name <> " val: " <> r.val <> " }"

readXml :: Foreign -> F XmlElement
readXml value = do
  name <- value ! "name" >>= readString 
  val  <- value ! "val" >>= readString 
  pure $ XmlElement { value: value, name: name, val: val }

xmlName :: XmlElement → String
xmlName (XmlElement xml) = xml.name

xmlVal :: XmlElement → String
xmlVal (XmlElement xml) = xml.val

foreign import xmlDocument :: String -> Foreign

xmldocE :: String → Either String XmlElement
xmldocE s = runExcept $ withExcept show $ readXml $ xmlDocument s

xmldoc :: String → Maybe XmlElement
xmldoc s = either (const Nothing) Just $ xmldocE s

foreign import childNamedJs :: Foreign -> String -> Foreign

childNamedE :: XmlElement → String → Either String XmlElement
childNamedE (XmlElement xml) name = runExcept $ withExcept show $ do
  mayb <- readUndefined $ childNamedJs xml.value name
  case mayb of
       Nothing -> fail (ForeignError "No child element found.")
       (Just xmlV) -> readXml xmlV

childNamed :: XmlElement -> String -> Maybe XmlElement
childNamed xml name = either (const Nothing) Just $ childNamedE xml name

