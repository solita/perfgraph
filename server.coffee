express = require "express"
http    = require "http"
path    = require "path"
mongodb = require "mongodb"
q       = require "q"
_       = require "lodash"
d3      = require "d3"
util    = require "util"
samples = require "./server/samples"

app     = express()

app.configure ->
  app.set "port", process.env.PORT or 3000
  app.set "host", process.env.IP or "0.0.0.0"
  app.use express.favicon()
  app.use express.logger("dev")
  app.use express.bodyParser() # Parse post-request body
  app.use express.methodOverride() # http://stackoverflow.com/questions/8378338/what-does-connect-js-methodoverride-do
  app.use app.router
  app.use express.static(path.join(__dirname, "public"))

  # Catch-all rule to handle reloads with client-side routing
  app.use (req, res) -> res.sendfile path.join(__dirname, "public/index.html")

app.configure "development", ->
  app.use express.errorHandler()

app.get "/response-time/:testCase", (req, res) ->
  testCases =
    lh: /Lainhuutotodistus/
    rt: /Rasitustodistus/
    vo: /Vuokraoikeus/

  samples.responseTimeTrend(testCases[req.params.testCase])
    .then (trend) -> res.send trend

app.get "/response-time-raw/:testCase", (req, res) ->
  samples.responseTimeRaw(req.params.testCase)
    .then (trend) -> res.send trend

app.get "/reports/:testCase/:build.json", (req, res) ->
  samples.report(req.params.testCase, req.params.build)
    .then (report) -> console.log report; res.send report

http.createServer(app).listen app.get("port"), app.get("host"), ->
  console.log "Express server listening on port " + app.get("port")
