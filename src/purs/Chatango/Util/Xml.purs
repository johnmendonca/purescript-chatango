module Chatango.Util.Xml where

import Prelude
import Data.Foreign (Foreign)
import Data.Foreign.Class (class IsForeign, read, readProp)
import Control.Monad.Except (runExcept, withExcept)
import Data.Either (Either(..), either)
import Data.Foreign.Undefined (readUndefined, unUndefined)
import Data.Maybe (Maybe(..), maybe)

newtype XmlElement = XmlElement {
  value :: Foreign,
  name  :: String,
  val   :: String
}

instance xmlShow :: Show XmlElement where
  show (XmlElement r) = "xml { name: " <> r.name <> " val: " <> r.val <> " }"

instance xmlIsForeign :: IsForeign XmlElement where
  read value = do
    name <- readProp "name" value
    val  <- readProp "val"  value
    pure $ XmlElement { value: value, name: name, val: val }

xmlName :: XmlElement → String
xmlName (XmlElement xml) = xml.name

xmlVal :: XmlElement → String
xmlVal (XmlElement xml) = xml.val

foreign import xmlDocument :: String -> Foreign

xmldocE :: String → Either String XmlElement
xmldocE s = runExcept $ withExcept show $ read $ xmlDocument s

xmldoc :: String → Maybe XmlElement
xmldoc s = either (const Nothing) Just $ xmldocE s

foreign import childNamedJs :: Foreign -> String -> Foreign

childNamedE :: XmlElement → String → Either String XmlElement
childNamedE (XmlElement xml) name = do
  undef <- runExcept $ withExcept show $ readUndefined read $ childNamedJs xml.value name
  maybe (Left "No child element found.") Right (unUndefined undef)

childNamed :: XmlElement -> String -> Maybe XmlElement
childNamed xml name = either (const Nothing) Just $ childNamedE xml name

