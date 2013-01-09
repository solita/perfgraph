mongodb = require "mongodb"
Q       = require "q"
_       = require "lodash"
d3      = require "d3"

db      = Q.ninvoke mongodb.MongoClient, "connect", "mongodb://localhost/kios-perf"
samples = db.then (db) -> Q.ninvoke db, "collection", "samples"

exports.latestBuilds = latestBuilds = (testCaseId = {"$in": ["lh", "rt", "vo"]}, {limit} = {}) ->
  samples
    .then((samples) -> Q.ninvoke samples, "distinct", "build", testCaseId: testCaseId)
    .then((builds)  -> builds = builds.sort().reverse(); if limit then builds[0..limit - 1] else builds)

exports.saveResults = (results) ->
  samples
    .then((samples) -> Q.ninvoke samples, "insert", results)
    .fail(console.log)

exports.responseTimeTrendInBuckets = (testCaseId) ->
  Q.all([samples, latestBuilds(testCaseId, limit: 30)])
    .spread((samples, latestBuilds) ->
      cursor = samples
        .find({testCaseId: testCaseId, build: {$in: latestBuilds}}, {elapsedTime: 1, build: 1, _id: 0})
        .sort({build: 1, elapsedTime: 1})
        Q.ninvoke cursor, "toArray")
    .then((results) ->
      elapsedTimesByBuild = _.groupBy(results, "build")
      bucketSize = 5
      elapsedTimesByBuildInBuckets = _.map elapsedTimesByBuild, (samples, build) ->
        buckets = _.groupBy samples, (sample) -> bucketSize * Math.ceil sample.elapsedTime / bucketSize
        _.map buckets, (val, key) ->
          bucketSize: bucketSize
          bucket: parseInt key
          count:  val.length
          build:  parseInt build
          testCase: testCaseId

      _.flatten elapsedTimesByBuildInBuckets)
    .fail(console.log)

exports.report = (testCaseId, build) ->
  build = if build == "latest"
      latestBuilds(testCaseId).then((builds) -> builds[0])
    else
      parseInt build

  Q.all([samples, build])
    .spread((samples, build) ->
      cursor = samples
        .find({build: build, testCaseId: testCaseId},{
          elapsedTime: 1, build: 1, bytes: 1, label: 1,
          assertions: 1, timeStamp: 1, responseCode: 1, _id: 0})
        .sort({elapsedTime: -1})
      Q.ninvoke cursor, "toArray")
    .then((results) ->
      beginTime = d3.min results, (d) -> d.timeStamp
      _.map results, (d) ->
        d.failed         = (d.assertions.map (a) -> a.failure || a.error).reduce (r, f) -> r || f
        d.timeSinceStart = d.timeStamp - beginTime
        d)
    .fail(console.log)

