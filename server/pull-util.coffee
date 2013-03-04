Q           = require "q"
request     = require "request"
logger      = require("./logger").logger

class PullUtil
  # Entity is the one who knows how to get
  # testCaseUrl, buildListUrl, latestBuilds, parseResults and saveResults
  constructor: (@hostname, @port, @projectName, @testCaseFiles, @entity) ->
    @urlId = 0
    @urlDone = 0

  newTestFiles: () ->
    @newBuildNums().then((buildNumbers) =>

      reducer = (res, build) => res.concat(for tc in @testCaseFiles
        @getTestFile({build: build, testCase: tc})
          .then(@entity.parseResults)
          .then(@entity.saveResults)
          .fail(logger))

      buildNumbers.reduce reducer, [])

  newBuildNums: () ->
    Q.all([@availableBuildNums(), @entity.latestBuilds()])
      .spread(
        ((availableBuildNums, savedBuilds) ->
          logger "availableBuildNums: #{availableBuildNums}"
          logger "savedBuilds: #{savedBuilds}"
          newBuilds = availableBuildNums.filter (b) -> savedBuilds.indexOf(b) == -1
          logger "newBuilds: #{newBuilds}"
          newBuilds))
      .fail(logger)

  getTestFile: (d) ->
    logger "Processing build ##{d.build}, test case #{d.testCase}"
    url = @entity.testCaseUrl d.build, d.testCase
    @get(url).then (body) ->
      logger "build ##{d.build}, test case #{d.testCase} downloaded. File size: #{body.length}"
      d.samples = body
      testData =
        d: d
        url: url

  availableBuildNums: () ->
    @get(@entity.buildListUrl)
    .then(((body) ->
      json = JSON.parse(body)
      allBuilds = json.builds.map (b) -> b.number
      allBuilds.filter (b) -> b <= json.lastCompletedBuild.number))
    .fail(logger)

  get: (url) ->
    deferred = Q.defer()

    @urlId = @urlId + 1
    myUrlId = @urlId
    logger "Processing url: ##{@urlId} = #{url}"
    req = request {url: url, timeout: 600000}, (err, res, body) =>
      if err or res.statusCode != 200 or !body
        @urlDone = @urlDone + 1
        logger "Failed url ##{myUrlId}. #{@urlId-@urlDone} in queue"
        deferred.reject new Error "err: #{err} res.statusCode: #{res?.statusCode} url: ##{myUrlId}"
      else
        @urlDone = @urlDone + 1
        logger "Got url ##{myUrlId}. #{@urlId-@urlDone} in queue"
        deferred.resolve body
    deferred.promise

exports.PullUtil = PullUtil
