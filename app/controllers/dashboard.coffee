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
      testCases   = ["lh", "rt", "vo"]
      columnCount = @elem.find("tr:first-child td").length
      rowCount    = testCases.length
      height      = $(window).height() * 0.83 / (rowCount)
      width       = $(window).width() * 0.83 / (columnCount)

      @elem.find(".graph").width(width).height(height)

      proto = @elem.find("tr.proto")
      gs = []
      for t in testCases
        do (t) =>
          n = proto.clone()
          proto.parent().append(n)
          g = new ResponseTimeHeatMap n.find(".response-time"), "/response-time-trend/#{t}"
          gs.push g
          g = new ResponseTimeScatterPlot n.find(".response-time.scatter-plot"), "/reports/#{t}/latest.json", 0.5
          g.elem.on("click", (d) -> page "/reports/#{t}/latest")
          gs.push g

      @graphs = gs
      proto.remove()

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
