mongodb = require "mongodb"
Q       = require "q"
_       = require "lodash"
d3      = require "d3"

db      = Q.ninvoke mongodb.MongoClient, "connect", "mongodb://localhost/kios-perf"
batches = db.then (db) -> Q.ninvoke db, "collection", "batches"

exports.latestBuilds = latestBuilds = (testCaseId = {"$in": ["01"]}, {limit} = {}) ->
  batches
    .then((batches) -> Q.ninvoke batches, "distinct", "build", testCaseId: testCaseId)
    .then((builds)  -> builds = builds.sort().reverse(); if limit then builds[0..limit - 1] else builds)

exports.saveResults = (results) ->
  batches
    .then((batches) -> Q.ninvoke batches, "insert", results)
    .fail(console.log)

exports.parseResults = (testData) ->
  tr = testData.d
  url = testData.url
  console.log "Parsing JTL test file: build ##{tr.build}, test case #{tr.testCase}"

  # xml2js uses sax-js, which often fails for invalid xml files
  # Use ugly regexp to "validate" JML by checking the existence of the end tag
  # unless tr.samples.match /<\/testResults>/
  #   throw new Error("Invalid JML file. Url: #{url}")

  parser = new xml2js.Parser()
  Q.ninvoke(parser, "parseString", tr.samples).then (bodyJson) ->
    throw Error bodyJson
    # for sample in bodyJson?.testResults?.httpSample || []
    #   testCaseId:     testCases[tr.testCase]
    #   testCase:       tr.testCase
    #   responseStatus: parseInt sample.$.rc
    #   build:          parseInt tr.build
    #   elapsedTime:    parseInt(sample.$.t) / 1000
    #   latencyTime:    parseInt(sample.$.lt) / 1000
    #   timeStamp:      parseInt(sample.$.ts) / 1000
    #   responseCode:   parseInt sample.$.rc
    #   label:          sample.$.lb
    #   bytes:          parseInt sample.$.by
    #   assertions:     for s in sample.assertionResult
    #     assertion =
    #       name: s.name[0]
    #       failure: s.failure[0] == 'true'
    #       error: s.error[0] == 'true'

    #     assertion["failureMessage"] = s.failureMessage[0] if s.failureMessage
    #     assertion["errorMessage"]   = s.errorMessage[0]   if s.errorMessage
    #     assertion
