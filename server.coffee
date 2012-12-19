express = require "express"
http    = require "http"
path    = require "path"
mongodb = require "mongodb"
q       = require "q"
_       = require "lodash"
d3      = require "d3"
util    = require "util"

app     = express()
db      = q.ninvoke mongodb.MongoClient, "connect", "mongodb://localhost/kios-perf"
samples = db.then (db) -> q.ninvoke db, "collection", "samples"

responseTimeTrend = (testCase) ->
  builds = samples
    .then((samples) -> q.ninvoke samples, "distinct", "build")
    .then((builds) -> builds.sort().reverse()[..29])

  q.all([samples, builds])
    .spread((samples, builds) ->
      cursor = samples
        .find({testCase: testCase, build: {$in: builds}}, {responseTime: 1, build: 1})
        .sort({build: 1, responseTime: 1})
      q.ninvoke cursor, "toArray")
    .then((results) ->
      responseTimesByBuild = _.values _.groupBy(results, "build")
      percentilesByBuild   = _.map responseTimesByBuild, (build) ->
        responseTimes = _.map build, (d) -> d.responseTime

        build: build[0].build
        median: d3.median(responseTimes) / 1000
        min: d3.min(responseTimes) / 1000
        max: d3.max(responseTimes) / 1000
        lowerPercentile: d3.quantile(responseTimes, 0.25) / 1000
        upperPercentile: d3.quantile(responseTimes, 0.75) / 1000)
    .fail(console.log)

responseTimeRaw = (testCase) ->
  builds = samples
    .then((samples) -> q.ninvoke samples, "distinct", "build")
    .then((builds) -> builds.sort().reverse()[..29])

  q.all([samples, builds])
    .spread((samples, builds) ->
      cursor = samples
        .find({testCase: testCase, build: {$in: builds}}, {responseTime: 1, build: 1, _id: 0})
        .sort({build: 1, responseTime: 1})
      q.ninvoke cursor, "toArray")
    .then((results) ->
      responseTimesByBuild = _.groupBy(results, "build")
      responseTimesByBuild5sBuckets = _.map responseTimesByBuild, (samples, build) ->
        buckets = _.groupBy samples, (sample) -> 5 * Math.ceil sample.responseTime / 5000
        _.map buckets, (val, key) ->
          bucket: parseInt key
          count:  val.length
          build:  parseInt build

      _.flatten responseTimesByBuild5sBuckets)
    .fail(console.log)

responseTimeRaw(/Rasitustodistus/).done()

app.configure ->
  app.set "port", process.env.PORT or 3000
  app.set "host", process.env.IP or "0.0.0.0"
  app.use express.favicon()
  app.use express.logger("dev")
  app.use express.bodyParser() # Parse post-request body
  app.use express.methodOverride() # http://stackoverflow.com/questions/8378338/what-does-connect-js-methodoverride-do
  app.use app.router
  app.use express.static(path.join(__dirname, "public"))

app.configure "development", ->
  app.use express.errorHandler()

app.get "/response-time/:testCase", (req, res) ->
  testCases =
    lh: /Lainhuutotodistus/
    rt: /Rasitustodistus/
    vo: /Vuokraoikeus/

  responseTimeTrend(testCases[req.params.testCase])
    .then (trend) -> res.end JSON.stringify trend

app.get "/response-time-raw/:testCase", (req, res) ->
  testCases =
    lh: /Lainhuutotodistus/
    rt: /Rasitustodistus/
    vo: /Vuokraoikeus/

  responseTimeRaw(testCases[req.params.testCase])
    .then (trend) -> res.end JSON.stringify trend

http.createServer(app).listen app.get("port"), app.get("host"), ->
  console.log "Express server listening on port " + app.get("port")
