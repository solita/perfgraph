mongodb = require "mongodb"
q       = require "q"
_       = require "lodash"
d3      = require "d3"

db      = q.ninvoke mongodb.MongoClient, "connect", "mongodb://localhost/kios-perf"
samples = db.then (db) -> q.ninvoke db, "collection", "samples"

testCases =
  lh: /Lainhuutotodistus/
  rt: /Rasitustodistus/
  vo: /Vuokraoikeus/

exports.responseTimeTrend = (testCase) ->
  testCase = testCases[testCase]
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

exports.responseTimeRaw = (testCaseUrl) ->
  testCase = testCases[testCaseUrl]
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
          testCase: testCaseUrl

      _.flatten responseTimesByBuild5sBuckets)
    .fail(console.log)

exports.report = (testCase, build) ->
  testCase = testCases[testCase]
  samples
    .then((samples) ->
      cursor = samples.find(
        {build: parseInt(build), testCase: testCase},
        {responseTime: 1, build: 1, elapsedTimeMs: 1, timestamp: 1, responseCode: 1, _id: 0})

      q.ninvoke cursor, "toArray")
    .fail(console.log)

