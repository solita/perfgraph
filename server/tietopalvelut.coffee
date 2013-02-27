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
  '01-ealh-kunta-md.xml':
    id:  'ealh/kunta'
    api: 'eraajo'
  '01-ealh-muutos-md.xml':
    id:  'ealh/muutos'
    api: 'eraajo'
  '01-ealh-luov-md.xml':
    id:  'ealh/luov'
    api: 'eraajo'
  '02-kypt-kunta-md.xml':
    id:  'kypt/kunta'
    api: 'kyselypalvelu'
  '02-kypt-muutos-md.xml':
    id:  'kypt/muutos'
    api: 'kyselypalvelu'
  '02-kypt-luov-md.xml':
    id:  'kypt/luov'
    api: 'kyselypalvelu'
  '05-kyom-tunnus-md.xml':
    id:  'kypt/tunnus'
    api: 'kyselypalvelu'

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
    .then((builds)  -> builds = builds.sort().reverse(); if limit then builds[0..limit - 1] else builds)

exports.latestBuildsForApi = latestBuildsForApi = (api, {limit} = {}) ->
  eraajot
    .then((eraajot) -> Q.ninvoke eraajot, "distinct", "build", api: api)
    .then((builds)  -> builds = builds.sort().reverse(); if limit then builds[0..limit - 1] else builds)

exports.saveResults = (results) ->
  eraajot
    .then((eraajot) -> Q.ninvoke eraajot, "insert", results)
    .fail(logger)

exports.throughput = (api) ->

  Q.all([eraajot, latestBuildsForApi(api, limit:15)])
    .spread((eraajot, latestBuildsForApi) ->
      cursor = eraajot
        .find(
          {build: {"$in": latestBuildsForApi}, api: api},
          {testCaseId: 1, build: 1, itemCount: 1, elapsedTime: 1, errorCount: 1, _id: 0 })
        .sort({build: 1})
      Q.ninvoke(cursor, "toArray").then( (results) ->
        results = _.map results, (d) ->
          d.throughput = d.itemCount / d.elapsedTime
          delete d.itemCount
          delete d.elapsedTime
          d
        results = _.groupBy results, (d) -> d.testCaseId
        _.values results))

exports.parseResults = (testData) ->
  tr = testData.d
  url = testData.url
  logger "Parsing test file: build ##{tr.build}, test case #{tr.testCase}"

  parser = new xml2js.Parser()
  Q.ninvoke(parser, "parseString", tr.samples).then (bodyJson) ->
    data = bodyJson["y:metatiedot"]
    throw Error("No 'metatiedot' tag found") unless data
    result =
      api:         testCases[tr.testCase]?.api
      testCaseId:  testCases[tr.testCase]?.id
      testCase:    tr.testCase
      build:       parseInt tr.build
      elapsedTime: parseInt(data["y:tiedostonLuonninKestoMillisekunteina"][0]) / 1000
      timeStamp:   moment(data["y:tiedostonLuontiaika"][0]).valueOf()
      itemCount:   parseInt data["y:kohteidenLukumaara"][0]
      errorCount:  parseInt data["y:virheellistenKohteidenLukumaara"]?[0] || 0

pullUtil = new PullUtil(hostname, port, projectName, _.keys(testCases), exports)
