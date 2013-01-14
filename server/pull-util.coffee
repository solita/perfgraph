Q           = require "q"
request     = require "request"

class PullUtil
  # Entity is the one who knows how to get latestBuilds, parseResults and saveResults
  constructor: (@hostname, @port, @projectName, @testCases, @entity) ->

  newTestFiles: () ->
    @newBuildNums().then((buildNumbers) =>
      jtlFiles = Object.keys(@testCases)

      reducer = (res, build) => res.concat(for tc in jtlFiles
        @getTestFile({build: build, testCase: tc})
          .then(@entity.parseResults)
          .then(@entity.saveResults)
          .fail(console.log))

      buildNumbers.reduce reducer, [])

  newBuildNums: () ->
    Q.all([@availableBuildNums(), @entity.latestBuilds()])
      .spread(
        ((availableBuildNums, savedBuilds) ->
          console.log "availableBuildNums: #{availableBuildNums}"
          console.log "savedBuilds: #{savedBuilds}"
          newBuilds = availableBuildNums.filter (b) -> savedBuilds.indexOf(b) == -1
          console.log "newBuilds: #{newBuilds}"
          newBuilds))
      .fail(console.log)

  getTestFile: (d) ->
    console.log "Processing build ##{d.build}, test case #{d.testCase}"

    jtlPath = "job/#{@projectName}/#{d.build}/artifact/kios-tp-performance/target/jmeter/report/#{d.testCase}"
    url = "http://#{@hostname}:#{@port}/#{jtlPath}"
    @get(url).then (samples) ->
      fileSize = (samples.charCodeAt(i) for s, i in samples).length
      console.log "build ##{d.build}, test case #{d.testCase} downloaded. File size: #{fileSize}"
      d.samples = samples
      testData =
        d: d
        url: url

  availableBuildNums: () ->
    @get("http://#{@hostname}:#{@port}/job/#{@projectName}/api/json")
    .then(((body) ->
      json = JSON.parse(body)
      allBuilds = json.builds.map (b) -> b.number
      allBuilds.filter (b) -> b <= json.lastCompletedBuild.number))
    .fail(console.log)

  get: (url) ->
    deferred = Q.defer()
    req = request {url: url, timeout: 600000}, (err, res, body) ->
      if err or res.statusCode != 200
        deferred.reject new Error "err: #{err} res.statusCode: #{res?.statusCode} url: #{url}"
      else
        deferred.resolve body
    deferred.promise

exports.PullUtil = PullUtil
