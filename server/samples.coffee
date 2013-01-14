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

maxResponseTimeInBuilds = (builds) ->
  samples.then((samples) ->
      cursor = samples
        .find({build: {$in: builds}}, {elapsedTime: 1, _id: 0})
        .sort(elapsedTime: -1)
        .limit(1)
      Q.ninvoke cursor, "toArray")
    .then((maxResponseTimeArr) -> maxResponseTimeArr[0].elapsedTime)

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
      Q.all([Q.ninvoke(cursor, "toArray"), maxResponseTimeInBuilds(latestBuilds)]))
    .spread((results, maxResponseTime) ->
      responseTimesByBuild = _.groupBy(results, "build")
      bucketSize = 5
      responseTimesByBuildInBuckets = _.map responseTimesByBuild, (samples, build) ->
        buckets = _.groupBy samples, (sample) -> bucketSize * Math.ceil sample.elapsedTime / bucketSize
        _.map buckets, (val, key) ->
          bucket: parseInt key
          count:  val.length
          build:  parseInt build

      data =
        testCase: testCaseId
        bucketSize: bucketSize
        maxResponseTimeBucket: bucketSize * Math.ceil maxResponseTime / bucketSize
        buckets: _.flatten responseTimesByBuildInBuckets)
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

exports.parseResults = (testData) ->
  tr = testData.d
  url = testData.url
  console.log "Parsing JTL test file: build ##{tr.build}, test case #{tr.testCase}"

  # xml2js uses sax-js, which often fails for invalid xml files
  # Use ugly regexp to "validate" JML by checking the existence of the end tag
  unless tr.samples.match /<\/testResults>/
    throw new Error("Invalid JML file. Url: #{url}")

  parser = new xml2js.Parser()
  Q.ninvoke(parser, "parseString", tr.samples).then (bodyJson) ->
    for sample in bodyJson?.testResults?.httpSample || []
      testCaseId:     testCases[tr.testCase]
      testCase:       tr.testCase
      responseStatus: parseInt sample.$.rc
      build:          parseInt tr.build
      elapsedTime:    parseInt(sample.$.t) / 1000
      latencyTime:    parseInt(sample.$.lt) / 1000
      timeStamp:      parseInt(sample.$.ts) / 1000
      responseCode:   parseInt sample.$.rc
      label:          sample.$.lb
      bytes:          parseInt sample.$.by
      assertions:     for s in sample.assertionResult
        assertion =
          name: s.name[0]
          failure: s.failure[0] == 'true'
          error: s.error[0] == 'true'

        assertion["failureMessage"] = s.failureMessage[0] if s.failureMessage
        assertion["errorMessage"]   = s.errorMessage[0]   if s.errorMessage
        assertion
