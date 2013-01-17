mongodb     = require "mongodb"
Q           = require "q"
_           = require "lodash"
d3          = require "d3"
xml2js      = require "xml2js"
MongoClient = require("mongodb").MongoClient
PullUtil    = require("./pull-util").PullUtil

hostname    = "ceto.solita.fi"
port        = 9080
projectName = "KIOS%20Perf%20Test%20TP%20tulosteet%20tomcat-kios%20at%20ceto"

testCases   =
  'KIOS-TP_TP_Lainhuutotodistus_pdf.jtl': 'lh'
  'KIOS-TP_TP_Rasitustodistus_pdf.jtl': 'rt'
  'KIOS-TP_TP_Vuokraoikeustodistus_pdf.jtl': 'vo'

db          = Q.ninvoke mongodb.MongoClient, "connect", "mongodb://localhost/kios-perf"
samples     = db.then (db) -> Q.ninvoke db, "collection", "samples"

exports.testCaseUrl = (build, testCase) ->
  "http://#{hostname}:#{port}/job/#{projectName}/#{build}/artifact/kios-tp-performance/target/jmeter/report/#{testCase}"

exports.buildListUrl = "http://#{hostname}:#{port}/job/#{projectName}/api/json"

exports.processTestResults = () ->
  pullUtil.newTestFiles().fail(console.log).allResolved()

exports.latestBuilds = latestBuilds = (testCaseId = {"$in": ["lh", "rt", "vo"]}, {limit} = {}) ->
  samples
    .then((samples) -> Q.ninvoke samples, "distinct", "build", testCaseId: testCaseId)
    .then((builds)  -> builds = builds.sort().reverse(); if limit then builds[0..limit - 1] else builds)

maxResponseTimeInBuilds = (builds) ->
  samples.then((samples) ->
      cursor = samples
        .find({build: {$in: builds}}, {elapsedTime: 1, timeStamp: 1, _id: 0})
        .sort(timeStamp: 1)
        .skip(1)
        .sort(elapsedTime: -1)
        .limit(1)
      Q.ninvoke cursor, "toArray")
    .then((maxResponseTimeArr) -> maxResponseTimeArr[0].elapsedTime)

exports.saveResults = (results) ->
  samples
    .then((samples) -> Q.ninvoke samples, "insert", results)
    .fail(console.log)

exports.responseTimeTrendInBuckets = (testCaseId) ->
  bucketSize = 5
  buckle = (elapsedTime) -> Math.max(bucketSize, bucketSize * Math.ceil elapsedTime / bucketSize)

  Q.all([samples, latestBuilds(testCaseId, limit: 30)])
    .spread((samples, latestBuilds) ->
      cursor = samples
        .find({testCaseId: testCaseId, build: {$in: latestBuilds}}, {elapsedTime: 1, build: 1, _id: 0})
        .sort({build: 1, elapsedTime: 1})
      Q.all([Q.ninvoke(cursor, "toArray"), maxResponseTimeInBuilds(latestBuilds)]))
    .spread((results, maxResponseTime) ->
      responseTimesByBuild = _.groupBy(results, "build")

      responseTimesByBuildInBuckets = _.map responseTimesByBuild, (samples, build) ->
        buckets = _.groupBy samples, (sample) -> buckle sample.elapsedTime
        _.map buckets, (val, key) ->
          bucket: parseInt key
          count:  val.length
          build:  parseInt build

      data =
        testCase: testCaseId
        bucketSize: bucketSize
        maxResponseTimeBucket: buckle maxResponseTime
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
          elapsedTime: 1, bytes: 1, label: 1,
          assertions: 1, timeStamp: 1, responseCode: 1, _id: 0})
        .sort({elapsedTime: -1})
      Q.all([Q.ninvoke(cursor, "toArray"), maxResponseTimeInBuilds([build])]))
    .spread((samples, maxResponseTime) ->
      beginTime = d3.min samples, (d) -> d.timeStamp
      samples = _.map samples, (d) ->
        d.failed         = (d.assertions.map (a) -> a.failure || a.error).reduce (r, f) -> r || f
        d.timeSinceStart = d.timeStamp - beginTime
        delete d.assertions
        d

      data =
        maxElapsedTimeInBuild: maxResponseTime
        samples: samples)
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

pullUtil = new PullUtil(hostname, port, projectName, testCases, exports)
