mongodb     = require "mongodb"
Q           = require "q"
_           = require "lodash"
d3          = require "d3"
xml2js      = require "xml2js"
MongoClient = require("mongodb").MongoClient
PullUtil    = require("./pull-util").PullUtil
logger      = require("./logger").logger

hostname    = "ceto.solita.fi"
port        = 9080
projectName = "KIOS%20Perf%20Test%20SRV%20tomcat-kios%20at%20ceto"

parser = new xml2js.Parser()

testCases   =
  'KIOS-SRV_Liittymat_kirre_omistustietopalvelu_erityisella_oikeudella.jtl': 'otpeo'
  'KIOS-SRV_Liittymat_kirre_omistustietopalvelu_kohdetunnuksella.jtl': 'otpkt'
  'KIOS-SRV_Liittymat_kirre_omistustietopalvelu_kohdetunnuksella_vakio_heinola_jokeri.jtl': 'otpktheijok'
  'KIOS-SRV_Liittymat_kirre_omistustietopalvelu_kohdetunnuksella_vakio_jokeri.jtl': 'otpktvakjok'
  'KIOS-SRV_Liittymat_kirre_omistustietopalvelu_laitostunnuksella.jtl': 'otplt'
  'KIOS-SRV_Liittymat_kirre_omistustietopalvelu_tunnuksella.jtl': 'otptunn'
  'KIOS-SRV_Liittymat_kirre_omistustietopalvelu_ytunnuksella_suuromistajat.jtl': 'otpytunnso'
  'KIOS-SRV_Liittymat_kirre_omistustietopalvelu_ytunnuksella_suuromistajat_lkm.jtl': 'otpytunnsolkm'

testCaseIds   = _.values testCases
_db           = Q.ninvoke(mongodb.MongoClient, "connect", "mongodb://localhost/kios-perf")
db            = _db.then((db) -> Q.ninvoke(db, 'ensureIndex', 'services', {build: 1, elapsedTime: 1}).then(-> db))
services      = db.then (db) -> Q.ninvoke db, "collection", "services"

exports.testCaseUrl = (build, testCase) ->
  "http://#{hostname}:#{port}/job/#{projectName}/#{build}/artifact/kios-services-performance/target/jmeter/report/#{testCase}"

exports.buildListUrl = "http://#{hostname}:#{port}/job/#{projectName}/api/json"

exports.processTestResults = ->
  pullUtil.newTestFiles().fail(logger).allResolved().then(-> db).then((db) -> db.close()).done()

exports.latestBuilds = latestBuilds = (testCaseId = {"$in": testCaseIds}, {limit} = {}) ->
  services
    .then((services) -> Q.ninvoke services, "distinct", "build", testCaseId: testCaseId)
    .then((builds)  -> builds = builds.sort().reverse(); if limit then builds[0..limit - 1] else builds)

maxResponseTimeInBuilds = (builds) ->
  services.then((services) ->
      cursor = services
        .find({build: {$in: builds}}, {elapsedTime: 1, timeStamp: 1, _id: 0})
        .sort(timeStamp: 1)
        .skip(1)
        .sort(elapsedTime: -1)
        .limit(1)
      Q.ninvoke cursor, "toArray")
    .then((maxResponseTimeArr) -> maxResponseTimeArr[0].elapsedTime)

exports.saveResults = (results) ->
  services
    .then((services) -> Q.ninvoke services, "insert", results)
    .fail(logger)

exports.responseTimeTrendInBuckets = (testCaseId) ->
  bucketSize = 1
  buckle = (elapsedTime) -> Math.max(bucketSize, bucketSize * Math.ceil elapsedTime / bucketSize)

  Q.all([services, latestBuilds(testCaseId, limit: 15)])
    .spread((services, latestBuilds) ->
      cursor = services
        .find({testCaseId: testCaseId, build: {$in: latestBuilds}}, {elapsedTime: 1, build: 1, _id: 0})
        .sort({build: 1, elapsedTime: 1})
      Q.all([Q.ninvoke(cursor, "toArray"), maxResponseTimeInBuilds(latestBuilds)]))
    .spread((results, maxResponseTime) ->
      responseTimesByBuild = _.groupBy(results, "build")

      responseTimesByBuildInBuckets = _.map responseTimesByBuild, (services, build) ->
        buckets = _.groupBy services, (sample) -> buckle sample.elapsedTime
        _.map buckets, (val, key) ->
          bucket: parseInt key
          count:  val.length
          build:  parseInt build

      data =
        project: "services"
        testCase: testCaseId
        bucketSize: bucketSize
        maxResponseTimeBucket: buckle maxResponseTime
        buckets: _.flatten responseTimesByBuildInBuckets)
    .fail(logger)

exports.report = (testCaseId, build) ->
  build = if build == "latest"
      latestBuilds(testCaseId).then((builds) -> builds[0])
    else
      parseInt build

  Q.all([services, build])
    .spread((services, build) ->
      cursor = services
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
    .fail(logger)

exports.parseResults = (testData) ->
  tr = testData.d
  url = testData.url
  logger "Parsing JTL test file: build ##{tr.build}, test case #{tr.testCase}"

  # xml2js uses sax-js, which often fails for invalid xml files
  # Use ugly regexp to "validate" JML by checking the existence of the end tag
  unless tr.samples.match /<\/testResults>/
    throw new Error("Invalid JML file. Url: #{url}")

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

pullUtil = new PullUtil(hostname, port, projectName, _.keys(testCases), exports)
