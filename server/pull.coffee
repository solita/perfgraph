Q = require "q"
request = require "request"
xml2js = require "xml2js"
MongoClient = require("mongodb").MongoClient
util = require "util"

hostname    = "ceto.solita.fi"
port        = 9080
projectName = "KIOS%20Perf%20Test%20TP%20tulosteet%20tomcat-kios%20at%20ceto"

get = (url) ->
  deferred = Q.defer()
  request url, (err, res, body) ->
    if err or res.statusCode != 200
      deferred.reject new Error "err: #{err} res.statusCode: #{res?.statusCode}"
    else
      deferred.resolve body
  deferred.promise

db      = Q.ninvoke MongoClient, "connect", "mongodb://localhost/kios-perf"
samples = db.then (db) -> Q.ninvoke db, "collection", "samples"

savedBuildNums = samples.then (samples) -> Q.ninvoke samples, "distinct", "build"

availableBuildNums = get("http://#{hostname}:#{port}/job/#{projectName}/api/json")
  .then(((body) -> JSON.parse(body).builds.map (b) -> b.number))

newBuildNums = Q.all([availableBuildNums, savedBuildNums])
  .spread(
    ((availableBuildNums, savedBuildNums) -> availableBuildNums.filter (b) -> savedBuildNums.indexOf(b) == -1))

getTestFile = (d) ->
  console.log "Processing build ##{d.build}, test case #{d.testCase}"
  jtlPath = "/job/#{projectName}/#{d.build}/artifact/kios-tp-performance/target/jmeter/report/#{d.testCase}"
  get("http://#{hostname}:#{port}/#{jtlPath}").then (samples) ->
    d.samples = samples
    d

parseResults = (tr) ->
  parser = new xml2js.Parser()
  Q.ninvoke(parser, "parseString", tr.samples).then (bodyJson) ->
    for sample in bodyJson?.testResults?.httpSample || []
      testCase:       tr.testCase
      assertions:     sample.assertionResult
      responseStatus: parseInt sample.$.rc
      build:          parseInt tr.build
      elapsedTime:    parseInt sample.$.t
      latencyTime:    parseInt sample.$.lt
      timeStamp:      parseInt sample.$.ts
      responseCode:   parseInt sample.$.rc
      label:          sample.$.lb
      bytes:          parseInt sample.$.by

saveResults = (results) ->
  samples.then (samples) -> Q.ninvoke samples, "insert", results

testResults = newBuildNums.then (buildNumbers) ->
  testCases = [
    'KIOS-TP_TP_Lainhuutotodistus_pdf.jtl',
    'KIOS-TP_TP_Rasitustodistus_pdf.jtl',
    'KIOS-TP_TP_Vuokraoikeustodistus_pdf.jtl']

  reducer = (res, build) -> res.concat(for tc in testCases
    getTestFile({build: build, testCase: tc})
      .then(parseResults)
      .then(saveResults, console.log))

  buildNumbers.reduce reducer, []

testResults
  .allResolved()
  .fin(-> db.then (db) -> db.close())
  .done()
