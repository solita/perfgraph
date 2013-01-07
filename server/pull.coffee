Q           = require "q"
request     = require "request"
xml2js      = require "xml2js"
MongoClient = require("mongodb").MongoClient
samples     = require "./samples"

hostname    = "ceto.solita.fi"
port        = 9080
projectName = "KIOS%20Perf%20Test%20TP%20tulosteet%20tomcat-kios%20at%20ceto"

testCases =
  'KIOS-TP_TP_Lainhuutotodistus_pdf.jtl': 'lh'
  'KIOS-TP_TP_Rasitustodistus_pdf.jtl': 'rt'
  'KIOS-TP_TP_Vuokraoikeustodistus_pdf.jtl': 'vo'

get = (url) ->
  deferred = Q.defer()
  req = request {url: url, timeout: 600000}, (err, res, body) ->
    if err or res.statusCode != 200
      deferred.reject new Error "err: #{err} res.statusCode: #{res?.statusCode} url: #{url}"
    else
      deferred.resolve body
  deferred.promise

availableBuildNums = () ->
  get("http://#{hostname}:#{port}/job/#{projectName}/api/json")
    .then(((body) ->
      json = JSON.parse(body)
      allBuilds = json.builds.map (b) -> b.number
      allBuilds.filter (b) -> b <= json.lastCompletedBuild.number))
    .fail(console.log)

newBuildNums = () ->
  Q.all([availableBuildNums(), samples.latestBuilds()])
    .spread(
      ((availableBuildNums, savedBuilds) ->
        console.log availableBuildNums, savedBuilds
        availableBuildNums.filter (b) -> savedBuilds.indexOf(b) == -1))
    .fail(console.log)

getTestFile = (d) ->
  console.log "Processing build ##{d.build}, test case #{d.testCase}"

  jtlPath = "/job/#{projectName}/#{d.build}/artifact/kios-tp-performance/target/jmeter/report/#{d.testCase}"
  url = "http://#{hostname}:#{port}/#{jtlPath}"
  get(url).then (samples) ->
    fileSize = (samples.charCodeAt(i) for s, i in samples).length
    console.log "build ##{d.build}, test case #{d.testCase} downloaded. File size: #{fileSize}"
    d.samples = samples
    testData =
      d: d
      url: url

parseResults = (testData) ->
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

newTestFiles = () ->
  newBuildNums().then((buildNumbers) ->
      jtlFiles = Object.keys(testCases)

      reducer = (res, build) -> res.concat(for tc in jtlFiles
        getTestFile({build: build, testCase: tc})
          .then(parseResults)
          .then(samples.saveResults)
          .fail(console.log))

      buildNumbers.reduce reducer, [])

exports.processTestResults = () ->
  newTestFiles().fail(console.log).allResolved()
