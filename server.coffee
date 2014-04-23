express       = require "express"
http          = require "http"
path          = require "path"
io            = require "socket.io"
tulosteet     = require "./server/tulosteet"
services      = require "./server/services"
tietopalvelut = require "./server/tietopalvelut"
#memwatch      = require "memwatch"
exec          = require('child_process').exec
app           = express()

#memwatch.on('leak', (info) -> console.log info)
#memwatch.on('stats', (stats) -> console.log stats)

projects =
  tulosteet: tulosteet
  services:  services


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

app.get "/response-time-trend/:project/:testCaseId/:limit", ({params: {project, testCaseId, limit}}, res) ->
  p = projects[project]
  p.responseTimeTrendInBuckets(testCaseId, parseInt limit )
    .then((trend) -> res.send trend)
    .done()

app.get "/error-trend/:project/:testCase", ({params: {project, testCaseId}}, res) ->
  p = projects[project]
  p.errorTrend(testCaseId)
    .then((trend) -> res.send trend)
    .done()

app.get "/throughput/:api/:limit", ({params: {api, limit}}, res) ->
  tietopalvelut.throughput(api, parseInt limit)
    .then((trend) -> res.send trend)
    .done()

app.get "/reports/:project/:testCaseId/:build.json", ({params: {project, testCaseId, build}}, res) ->
  p = projects[project]
  p.report(testCaseId, build)
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
