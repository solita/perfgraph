define (require) ->
  $      = require "jquery"
  io     = require "socket.io"
  moment = require "moment"

  ErrorGraph              = require "controllers/error-graph"
  ResponseTimeHeatMap     = require "controllers/response-time-heat-map"
  ResponseTimeScatterPlot = require "controllers/response-time-scatterplot"
  TroughputLine           = require "controllers/throughput-line"

  class DashboardController

    updateCallback = (elem) ->
      (data, z) ->
        legendData = data.map (d) ->
          latestBuild = _.last(d)

          testCaseId: latestBuild.testCaseId
          build:      latestBuild.build
          throughput: latestBuild.throughput.toFixed 1
          errorCount:     latestBuild.errorCount

        elem.render legendData,
          stroke: style: -> "background-color: #{z(@testCaseId)}"

    constructor: (@elem) ->
      testCases   = ["lh", "rt", "vo", "lhro"]

      responseTimeTrends = for t in testCases
        new ResponseTimeHeatMap @elem.find(".#{t}.response-time"), "/response-time-trend/#{t}"

      responseTimeLatests = for t in testCases
        do (t) =>
          g = new ResponseTimeScatterPlot @elem.find(".#{t}.response-time-scatter-plot"), "/reports/#{t}/latest.json", 0.5
          g.elem.on("click", (d) -> page "/reports/#{t}/latest")
          g

      eaTroughput = new TroughputLine @elem.find(".eraajo.throughput"), "/ea-throughput.json", updateCallback @elem.find ".eraajo.tietopalvelu.status .tbody"
      kpTroughput = new TroughputLine @elem.find(".kyselypalvelu.throughput"), "/kp-throughput.json", updateCallback @elem.find ".kyselypalvelu.tietopalvelu.status .tbody"
      @graphs = responseTimeTrends.concat responseTimeLatests, [eaTroughput, kpTroughput]

      @updateButton = $(".update")
      @updateProgressIcon = $(".progress")
      @updateButton.on "click", @processBuilds

      @socket = io.connect()
      @socket.on "change", @update
      @socket.on "reload", -> location.reload true
      @update()

    processBuilds: =>
      @updateButton.prop "disabled", true
      @updateProgressIcon.removeClass "hidden"
      $.get "/process-builds"

    update: =>
      g.update() for g in @graphs
      @updateButton.prop "disabled", false
      @updateProgressIcon.addClass "hidden"

    hide: () -> $('.dashboard').addClass "hidden"
    show: () -> $('.dashboard').removeClass "hidden"
