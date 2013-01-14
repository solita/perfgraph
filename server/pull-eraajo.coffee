# Read, parse and store test results from eräajo artifacts
# Complete url to one test result in Jenkins
# http://ceto.solita.fi:9080/job/KIOS%20Perf%20Test%20TP%20eraajo%20velocity/13/artifact/kios-tp-eraajo-velocity-performance/target/01-irrotus-lhtiedot-kunta_kunta=21_olotila=1-md.xml

Q           = require "q"
request     = require "request"
xml2js      = require "xml2js"
MongoClient = require("mongodb").MongoClient
PullUtil    = require("./pull-util").PullUtil
batches     = require "./batches"

hostname    = "ceto.solita.fi"
port        = 9080
projectName = "KIOS%20Perf%20Test%20TP%20eraajo%20velocity"

testCases =
  '01-irrotus-lhtiedot-kunta_kunta=21_olotila=1': '01'

pullUtil = new PullUtil(hostname, port, projectName, testCases, batches)

exports.processTestResults = () ->
  pullUtil.newTestFiles().fail(console.log).allResolved()
