express       = require "express"
http          = require "http"
path          = require "path"
io            = require "socket.io"
tulosteet     = require "./server/tulosteet"
tietopalvelut = require "./server/tietopalvelut"
memwatch      = require "memwatch"
exec          = require('child_process').exec
app           = express()

memwatch.on('leak', (info) -> console.log info)
memwatch.on('stats', (stats) -> console.log stats)

app.configure ->
  app.set "port", process.env.PORT or 3000
  app.set "host", process.env.IP or "0.0.0.0"
  app.use express.favicon()
  app.use express.logger("dev")
  app.use express.compress()
  app.use express.bodyParser() # Parse post-request body
  app.use express.methodOverride() # http://stackoverflow.com/questions/8378338/what-does-connect-js-methodoverride-do
  app.use app.router
  app.use express.static(path.join(__dirname, "public"))

  # Catch-all rule to handle reloads with client-side routing
  app.use (req, res) -> res.sendfile path.join(__dirname, "public/index.html")

app.configure "development", ->
  app.use express.errorHandler()

app.get "/response-time-trend/:testCaseId", ({params: {testCaseId}}, res) ->
  tulosteet.responseTimeTrendInBuckets(testCaseId)
    .then((trend) -> res.send trend)
    .done()

app.get "/error-trend/:testCase", ({params: {testCaseId}}, res) ->
  tulosteet.errorTrend(testCaseId)
    .then((trend) -> res.send trend)
    .done()

app.get "/:api/throughput.json", ({params: {api}}, res) ->
  tietopalvelut.throughput(api)
    .then((trend) -> res.send trend)
    .done()

app.get "/reports/:testCaseId/:build.json", ({params: {testCaseId, build}}, res) ->
  tulosteet.report(testCaseId, build)
    .then((report) -> res.send report)
    .done()

processingBuilds = false
app.get "/process-builds", (req, res) ->
  res.send 200
  unless processingBuilds
    processingBuilds = true
    exec 'coffee ./server/pull.coffee', (err, stdout, stderr) ->
      processingBuilds = false
      console.log stdout, stderr
      io.sockets.emit "change"

app.get "/force-reload", (req, res) ->
  res.send 200; io.sockets.emit "reload"

server = http.createServer(app)
io     = io.listen(server)

server.listen app.get("port"), app.get("host"), ->
  console.log "Express server listening on port #{app.get("port")}"
