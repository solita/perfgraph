mongodb     = require "mongodb"
moment      = require "moment"
Q           = require "q"
_           = require "lodash"
d3          = require "d3"
xml2js      = require "xml2js"
MongoClient = require("mongodb").MongoClient
PullUtil    = require("./pull-util").PullUtil
logger      = require("./logger").logger

hostname    = "ceto.solita.fi"
port        = 9080
projectName = "KIOS%20Perf%20Test%20TP%20eraajo%20velocity"

testCases =
  '01-ealh-kunta-md.xml': { id: 'ealh-kunta', api: 'eraajo' }
  '01-ealh-luov-md.xml': { id: 'ealh-luov', api: 'eraajo' }
  '01-eara-kunta-md.xml': { id: 'eara-kunta', api: 'eraajo' }
  '01-eavo-kunta-md.xml': { id: 'eavo-kunta', api: 'eraajo' }
  '01-ealh-muutos-101-md.xml': { id: 'ealh-muutos-101', api: 'eraajo-muutos' }
  '01-ealh-muutos-102-md.xml': { id: 'ealh-muutos-102', api: 'eraajo-muutos' }
  '01-ealh-muutos-103-md.xml': { id: 'ealh-muutos-103', api: 'eraajo-muutos' }
  '01-ealh-muutos-104-md.xml': { id: 'ealh-muutos-104', api: 'eraajo-muutos' }
  '01-ealh-muutos-105-md.xml': { id: 'ealh-muutos-105', api: 'eraajo-muutos' }
  '01-eavo-muutos-112-md.xml': { id: 'eavo-muutos-112', api: 'eraajo-muutos' }
  '01-eavo-muutos-113-md.xml': { id: 'eavo-muutos-113', api: 'eraajo-muutos' }
  '02-kypt-kunta-ki-md.xml': { id: 'kypt-kunta-ki', api: 'kyselypalvelu-krkohde' }
  '02-kypt-kunta-ma-md.xml': { id: 'kypt-kunta-ma', api: 'kyselypalvelu-krkohde' }
  '02-kypt-kunta-vo-md.xml': { id: 'kypt-kunta-vo', api: 'kyselypalvelu' }
  '02-kypt-luov-ki-md.xml': { id: 'kypt-luov-ki', api: 'kyselypalvelu' }
  '02-kypt-luov-ma-md.xml': { id: 'kypt-luov-ma', api: 'kyselypalvelu' }
  '02-kypt-muutos-201-md.xml': { id: 'kypt-muutos-201', api: 'kyselypalvelu-muutos' }
  '02-kypt-muutos-202-md.xml': { id: 'kypt-muutos-202', api: 'kyselypalvelu-muutos' }
  '02-kypt-muutos-203-md.xml': { id: 'kypt-muutos-203', api: 'kyselypalvelu-muutos' }
  '02-kypt-muutos-204-md.xml': { id: 'kypt-muutos-204', api: 'kyselypalvelu-muutos' }
  '02-kypt-muutos-205-md.xml': { id: 'kypt-muutos-205', api: 'kyselypalvelu-muutos' }
  '02-kypt-muutos-206-md.xml': { id: 'kypt-muutos-206', api: 'kyselypalvelu-muutos' }
  '02-kypt-muutos-207-md.xml': { id: 'kypt-muutos-207', api: 'kyselypalvelu-muutos' }
  '02-kypt-muutos-208-md.xml': { id: 'kypt-muutos-208', api: 'kyselypalvelu-muutos' }
  '02-kypt-muutos-209-md.xml': { id: 'kypt-muutos-209', api: 'kyselypalvelu-muutos' }
  '02-kypt-muutos-210-md.xml': { id: 'kypt-muutos-210', api: 'kyselypalvelu-muutos' }
  '05-kyom-nimi-md.xml': { id: 'kyom-nimi', api: 'kyselypalvelu' }
  '05-kyom-tunnus-md.xml': { id: 'kyom-tunnus', api: 'kyselypalvelu' }

testCaseIds = _.map testCases, (a) -> a.id

db            = Q.ninvoke mongodb.MongoClient, "connect", "mongodb://localhost/kios-perf"
eraajot       = db.then (db) -> Q.ninvoke db, "collection", "eraajot"

exports.processTestResults = () ->
  pullUtil.newTestFiles().fail(logger).allResolved().then(-> db).then((db)-> db.close()).done()

exports.testCaseUrl = (build, testCase) ->
  "http://#{hostname}:#{port}/job/#{projectName}/#{build}/artifact/kios-tp-eraajo-velocity-performance/target/#{testCase}"

exports.buildListUrl = "http://#{hostname}:#{port}/job/#{projectName}/api/json"

exports.latestBuilds = latestBuilds = (testCaseId = {"$in": testCaseIds}, {limit} = {}) ->
  eraajot
    .then((eraajot) -> Q.ninvoke eraajot, "distinct", "build", testCaseId: testCaseId)
    .then((builds)  -> builds = builds.sort((a,b) -> b-a); if limit then builds[0..limit - 1] else builds)

exports.latestBuildsForApi = latestBuildsForApi = (api, {limit} = {}) ->
  eraajot
    .then((eraajot) -> Q.ninvoke eraajot, "distinct", "build", api: api)
    .then((builds)  -> builds = builds.sort((a,b) -> b-a); if limit then builds[0..limit - 1] else builds)

exports.saveResults = (results) ->
  eraajot
    .then((eraajot) -> Q.ninvoke eraajot, "insert", results)
    .fail(logger)

exports.throughput = (api) ->

  Q.all([eraajot, latestBuildsForApi(api, limit:30)])
    .spread((eraajot, latestBuildsForApi) ->
      cursor = eraajot
        .find(
          {build: {"$in": latestBuildsForApi}, api: api},
          {testCaseId: 1, build: 1, itemCount: 1, elapsedTime: 1, errorCount: 1, _id: 0 })
        .sort({build: 1})
      Q.ninvoke(cursor, "toArray").then( (results) ->
        results = _.map results, (d) ->
          d.throughput = d.itemCount / d.elapsedTime
          delete d.elapsedTime
          d
        results = _.groupBy results, (d) -> d.testCaseId
        _.values results))

exports.parseResults = (testData) ->
  tr = testData.d
  url = testData.url
  logger "Parsing test file: build ##{tr.build}, test case #{tr.testCase}"

  # Some testreports are missing xmlns for the metatiedot element.
  # We need it to be able to parse, so it is added here.
  tr.samples = tr.samples.replace '<y:metatiedot>', '<y:metatiedot xmlns:y="http://xml.nls.fi/ktjkir/yhteinen/2013/03/01">'

  parser = new xml2js.Parser()
  Q.ninvoke(parser, "parseString", tr.samples).then (bodyJson) ->
    data = bodyJson["y:metatiedot"]
    throw Error("No 'metatiedot' tag found in build ##{tr.build}, test case #{tr.testCase}") unless data

    # Different reports have slightly different element names.
    # For example "ealh-kunta" has: "kohteidenLukumaara" and
    # "kyom-tunnus" has "omistustenLukumaara"
    if data["y:kohteidenLukumaara"]
      itemCountTemp = parseInt data["y:kohteidenLukumaara"][0]
      errorCountTemp = parseInt data["y:virheellistenKohteidenLukumaara"]?[0] || 0
    else
      itemCountTemp = parseInt data["y:omistustenLukumaara"][0]
      errorCountTemp = parseInt data["y:virheellistenOmistustenLukumaara"]?[0] || 0

    result =
      api:         testCases[tr.testCase]?.api
      testCaseId:  testCases[tr.testCase]?.id
      testCase:    tr.testCase
      build:       parseInt tr.build
      elapsedTime: parseInt(data["y:tiedostonLuonninKestoMillisekunteina"][0]) / 1000
      timeStamp:   moment(data["y:tiedostonLuontiaika"][0]).valueOf()
      itemCount:   itemCountTemp
      errorCount:  errorCountTemp

pullUtil = new PullUtil(hostname, port, projectName, _.keys(testCases), exports)
