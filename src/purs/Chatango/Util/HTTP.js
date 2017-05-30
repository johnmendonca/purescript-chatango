// https://github.com/Thimoteus/purescript-simple-request/blob/master/src/Node/SimpleRequest.js

exports.responseBodyJs = function (stream) {
  return function (onErr) {
    return function (onSucc) {
      return function () {
        var body = "";
        stream.on("data", function (chunk) {
          body += chunk;
        });
        stream.on("end", function () {
          onSucc(body)();
        });
        stream.on("error", function (err) {
          onErr(err)();
        });
        return {};
      }
    }
  }
}

