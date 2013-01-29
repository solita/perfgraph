define (require) ->
  $      = require "jquery"
  io     = require "socket.io"
  moment = require "moment"

  ErrorGraph              = require "controllers/error-graph"
  ResponseTimeHeatMap     = require "controllers/response-time-heat-map"
  ResponseTimeScatterPlot = require "controllers/response-time-scatterplot"
  EraajoTroughput         = require "controllers/eraajo-throughput"

  class DashboardController
    constructor: (@elem) ->
      testCases   = ["lh", "rt", "vo", "lhro"]

      responseTimeTrends = for t in testCases
        new ResponseTimeHeatMap @elem.find(".#{t}.response-time"), "/response-time-trend/#{t}"

      responseTimeLatests = for t in testCases
        do (t) =>
          g = new ResponseTimeScatterPlot @elem.find(".#{t}.response-time-scatter-plot"), "/reports/#{t}/latest.json", 0.5
          g.elem.on("click", (d) -> page "/reports/#{t}/latest")
          g

      eraajoTroughput = new EraajoTroughput @elem.find(".eraajo.throughput"), "/eraajo-throughput.json"
      @graphs = responseTimeTrends.concat responseTimeLatests, [eraajoTroughput]

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
