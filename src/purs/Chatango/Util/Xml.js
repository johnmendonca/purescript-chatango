"use strict";

var XmlDoc = require('xmldoc');

exports.xmlDocument = function(s) {
  try {
    return new XmlDoc.XmlDocument(s);
  } catch (e) {
    return {};
  }
}

exports.childNamedJs = function(xml) {
  return function(s) {
    return xml.childNamed(s);
  }
}

