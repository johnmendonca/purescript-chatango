module Chatango.Urls where

import Prelude
import Data.Either (Either(..))
import Data.Maybe (Maybe(..), maybe)
import Data.String (Pattern(..), Replacement(..), charAt, fromCharArray, replace, singleton)

urlTemplates = {
  groupinfo: "http://ust.chatango.com/groupinfo/$/gprofile.xml", 
  format: "http://ust.chatango.com/profileimg/$/msgstyles.json",
  backgroundinfo: "http://ust.chatango.com/profileimg/$/msgbg.xml", 
  backgroundimage: "http://ust.chatango.com/profileimg/$/msgbg.jpg", 
  updatebackground: "http://chatango.com/updatemsgbg", 
  profile: "http://ust.chatango.com/profileimg/$/mod1.xml", 
  updateprofile: "http://chatango.com/updateprofile", 
  thumbnail: "http://fp.chatango.com/profileimg/$/thumb.jpg", 
  avatar: "http://fp.chatango.com/profileimg/$/full.jpg"
}

namePath :: String → Either String String
namePath name = maybe (Left "Name too short for url.") Right do
  a <- charAt 0 name
  b <- charAt 1 name
  Just $ fromCharArray [a, '/', b, '/'] <> name

fillTemplate :: String → String → Either String String
fillTemplate template name = do
  path <- namePath name
  Right $ replace (Pattern "$") (Replacement path) template

profileUrl = fillTemplate urlTemplates.profile
formatUrl = fillTemplate urlTemplates.format
groupinfoUrl = fillTemplate urlTemplates.groupinfo

