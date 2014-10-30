Q           = require "q"
request     = require "request"
logger      = require("./logger").logger
_           = require "lodash"

class PullUtil
  # Entity is the one who knows how to get
  # testCaseUrl, buildListUrl, latestBuilds, parseResults and saveResults
  constructor: (@hostname, @port, @projectName, @testCaseFiles, @entity) ->
    @urlId = 0
    @urlDone = 0

  getBuilds: (buildNumbers) ->
    Q.fcall( =>
        saneBuildNumbers = _.filter( buildNumbers, (n) -> parseInt(n) > 0 )
        console.log "Getting #{@entity.name} buildNumbers: [#{saneBuildNumbers}]"
        saneBuildNumbers.map( (b) -> parseInt(b) )
      ).then(@entity.removeBuilds).then(@pullBuilds)

  newTestFiles: () ->
    @newBuildNums().then(@pullBuilds)

  pullBuilds: (buildNumbers) =>
      reducer = (res, build) => res.concat(for tc in @testCaseFiles
        @getTestFile({build: build, testCase: tc})
          .then(@entity.parseResults)
          .then(@entity.saveResults)
          .fail(logger))

      buildNumbers.reduce reducer, []

  newBuildNums: () ->
    Q.all([@availableBuildNums(), @entity.latestBuilds()])
      .spread(
        ((availableBuildNums, savedBuilds) =>
          logger "#{@entity.name}: builds available for download: [#{availableBuildNums}]"
          logger "#{@entity.name}: builds already downloaded: [#{savedBuilds}]"
          newBuilds = availableBuildNums.filter (b) -> savedBuilds.indexOf(b) == -1
          logger "#{@entity.name}: builds to download now: [#{newBuilds}]"
          newBuilds))
      .fail(logger)

  getTestFile: (d) ->
    logger "Starting download of build #{@entity.name}:##{d.build}, test case #{d.testCase}"
    url = @entity.testCaseUrl d.build, d.testCase
    @get(url).then (body) =>
      logger "build #{@entity.name}:##{d.build}, test case #{d.testCase} downloaded. File size: #{body.length}"
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
    queueSize = @urlId-@urlDone
    if queueSize > 100
      @urlDone = @urlDone + 1
      deferred.reject new Error "Skipping url: #{@entity.name}:#{@urlId} = #{url} - too many urls (>100) at same time"
    else
      logger "Get url: #{@entity.name}:#{@urlId} = #{url}"
      request {url: url, timeout: 60000 + 1000 * queueSize }, (err, res, body) =>
        @urlDone = @urlDone + 1
        if err or res.statusCode != 200 or !body
          logger "Failed url #{@entity.name}:#{myUrlId}. #{@urlId-@urlDone} in queue"
          deferred.reject new Error "err: #{err} res.statusCode: #{res?.statusCode} url: #{@entity.name}:#{myUrlId}"
        else
          logger "Got url #{@entity.name}:#{myUrlId}. #{@urlId-@urlDone} in queue"
          deferred.resolve body
    deferred.promise

exports.PullUtil = PullUtil
