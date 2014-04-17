define (require) ->
  $      = require "jquery"
  io     = require "socket.io"
  moment = require "moment"
  _      = require "lodash"

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
          count:      latestBuild.itemCount
          errorCount: latestBuild.errorCount

        elem.render legendData,
          stroke: style: -> "background-color: #{z(@testCaseId)}"

    constructor: (@elem) ->
      tulosteetTestCases   =
        tulosteet: ["lhmu", "lhoulu", "lh", "rt", "vo", "lhro", "omyt", "vuyt"]
        services: ["otpeo", "otpkt", "otpktheijok", "otpktvakjok", "otplt", "otptunn", "otpytunnso", "otpytunnsolkm"]

      tietopalveluTestCases =
        ["eraajo", "kyselypalvelu", "kyselypalvelu-krkohde", "eraajo-muutos", "kyselypalvelu-muutos"]

      responseTimeTrends =
        for p in _.keys tulosteetTestCases
          for t in tulosteetTestCases[p]
            new ResponseTimeHeatMap @elem.find(".#{p}.#{t}.response-time"), "/response-time-trend/#{p}/#{t}"

      responseTimeLatests =
        for p in _.keys tulosteetTestCases
          for t in tulosteetTestCases[p]
            do (p, t) =>
              g = new ResponseTimeScatterPlot @elem.find(".#{p}.#{t}.response-time-scatter-plot"), "/reports/#{p}/#{t}/latest.json", 0.5
              g.elem.on("click", (d) -> page "/reports/#{p}/#{t}/latest")
              g

      throughputGraphs =
        for t in tietopalveluTestCases
          new TroughputLine @elem.find(".#{t}.throughput"), "/#{t}/throughput.json", updateCallback @elem.find ".#{t}.tietopalvelu.status .tbody"

      @graphs = _.flatten(responseTimeTrends.concat responseTimeLatests, throughputGraphs)

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
