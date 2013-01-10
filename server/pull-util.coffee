Q           = require "q"
request     = require "request"

exports.get = (url) ->
  deferred = Q.defer()
  req = request {url: url, timeout: 600000}, (err, res, body) ->
    if err or res.statusCode != 200
      deferred.reject new Error "err: #{err} res.statusCode: #{res?.statusCode} url: #{url}"
    else
      deferred.resolve body
  deferred.promise
