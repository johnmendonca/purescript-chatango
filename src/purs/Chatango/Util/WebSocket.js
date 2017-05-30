var WebSocket = require('ws');

exports.newWebSocketImpl = function(url) {
  return function(protocols) {
    return function(options) {
      return function() {
        return new WebSocket(url, protocols, options);
      }
    }
  }
}

exports.addNullHandler = function(socket) {
  return function(eventName) {
    return function(action) {
      return function() {
        return socket.on(eventName, action);
      }
    }
  }
}

function executeHandler(handler) {
  return function(str) {
    handler(str)();
  }
}

exports.addStringHandler = function(socket) {
  return function(eventName) {
    return function(handler) {
      return function() {
        return socket.on(eventName, executeHandler(handler));
      }
    }
  }
}

exports.send = function(socket) {
  return function(message) {
    return function() {
      try {
        socket.send(message);
      } catch(e) {
        console.log(e.name);
      }
      return {};
    }
  }
}

exports.close = function(socket) {
  return function() {
    socket.close();
    return {};
  }
}

