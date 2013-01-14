Q           = require "q"
xml2js      = require "xml2js"
MongoClient = require("mongodb").MongoClient
PullUtil    = require("./pull-util").PullUtil

hostname    = "ceto.solita.fi"
port        = 9080
projectName = "KIOS%20Perf%20Test%20TP%20tulosteet%20tomcat-kios%20at%20ceto"

testCases =
  'KIOS-TP_TP_Lainhuutotodistus_pdf.jtl': 'lh'
  'KIOS-TP_TP_Rasitustodistus_pdf.jtl': 'rt'
  'KIOS-TP_TP_Vuokraoikeustodistus_pdf.jtl': 'vo'


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

pullUtil = new PullUtil(hostname, port, projectName, testCases, parseResults)

exports.processTestResults = () ->
  pullUtil.newTestFiles().fail(console.log).allResolved()
