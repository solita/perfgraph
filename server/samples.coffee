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

exports.elapsedTimeTrend = (testCase) ->
  testCase = testCases[testCase]
  builds = samples
    .then((samples) -> q.ninvoke samples, "distinct", "build")
    .then((builds) -> builds.sort().reverse()[..29])

  q.all([samples, builds])
    .spread((samples, builds) ->
      cursor = samples
        .find({testCase: testCase, build: {$in: builds}}, {elapsedTime: 1, build: 1})
        .sort({build: 1, elapsedTime: 1})
      q.ninvoke cursor, "toArray")
    .then((results) ->
      elapsedTimesByBuild = _.values _.groupBy(results, "build")
      percentilesByBuild   = _.map elapsedTimesByBuild, (build) ->
        elapsedTimes = _.map build, (d) -> d.elapsedTime

        build: build[0].build
        median: d3.median elapsedTimes
        min: d3.min elapsedTimes
        max: d3.max elapsedTimes
        lowerPercentile: d3.quantile elapsedTimes, 0.25
        upperPercentile: d3.quantile elapsedTimes, 0.75)
    .fail(console.log)

exports.elapsedTimeRaw = (testCaseUrl) ->
  testCase = testCases[testCaseUrl]
  builds = samples
    .then((samples) -> q.ninvoke samples, "distinct", "build")
    .then((builds) -> builds.sort().reverse()[..29])

  q.all([samples, builds])
    .spread((samples, builds) ->
      cursor = samples
        .find({testCase: testCase, build: {$in: builds}}, {elapsedTime: 1, build: 1, _id: 0})
        .sort({build: 1, elapsedTime: 1})
      q.ninvoke cursor, "toArray")
    .then((results) ->
      elapsedTimesByBuild = _.groupBy(results, "build")
      elapsedTimesByBuild5sBuckets = _.map elapsedTimesByBuild, (samples, build) ->
        buckets = _.groupBy samples, (sample) -> 5 * Math.ceil sample.elapsedTime / 5
        _.map buckets, (val, key) ->
          bucket: parseInt key
          count:  val.length
          build:  parseInt build
          testCase: testCaseUrl

      _.flatten elapsedTimesByBuild5sBuckets)
    .fail(console.log)

exports.report = (testCase, build) ->
  testCase = testCases[testCase]
  samples
    .then((samples) ->
      cursor = samples
        .find({build: parseInt(build), testCase: testCase},
              {elapsedTime: 1, build: 1, bytes: 1, label: 1, timeStamp: 1, responseCode: 1, _id: 0})
        .sort({elapsedTime: -1})

      q.ninvoke cursor, "toArray")

    .then((results) ->
      beginTime = d3.min results, (d) -> d.timeStamp

      _.map results, (d) ->
        d.timeSinceStart = d.timeStamp - beginTime
        d)
    .fail(console.log)
