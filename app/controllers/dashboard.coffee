define (require) ->
  $      = require "jquery"
  io     = require "socket.io"
  moment = require "moment"

  ErrorGraph              = require "controllers/error-graph"
  ResponseTimeHeatMap     = require "controllers/response-time-heat-map"
  ResponseTimeScatterPlot = require "controllers/response-time-scatterplot"

  class DashboardController
    constructor: (@elem) ->
      # Set dimensions for the graphs
      columnCount = @elem.find("tr:first-child td").length
      rowCount    = @elem.find("tr").length
      height      = $(window).height() * 0.7 / (rowCount - 1)
      width       = $(window).width() * 0.7 / (columnCount - 1)
      testCases   = ["lh", "rt", "vo"]

      @elem.find(".graph").width(width).height(height)

      @responseTimeTrends = for t in testCases
        new ResponseTimeHeatMap @elem.find(".#{t}.response-time"), "/response-time-trend/#{t}"

      @responseTimeLatests = for t in testCases
        do (t) =>
          g = new ResponseTimeScatterPlot @elem.find(".#{t}.response-time.scatter-plot"), "/reports/#{t}/latest.json", 0.5
          g.elem.on("click", (d) -> page "/reports/#{t}/latest")
          g

      @graphs = @responseTimeTrends.concat @responseTimeLatests

      @socket = io.connect()
      @socket.on "change", @update
      @socket.on "reload", -> location.reload true
      @update()


    update: =>
      $(".updated").html moment().format "HH:mm <br /> D.M.YYYY"
      g.update() for g in @graphs

    hide: () -> $('.dashboard').addClass "hidden"
    show: () -> $('.dashboard').removeClass "hidden"
