define ["jquery",
        "controllers/error-graph",
        "controllers/response-time-graph",
        "controllers/response-time-heat-map",
        "controllers/response-time-scatterplot"], ($, ErrorGraph, ResponseTimeGraph, ResponseTimeHeatMap, ResponseTimeScatterPlot) ->

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

      @update()
      setInterval(@update, 60 * 1000)

    update: =>
      g.update() for g in @graphs


    hide: () -> $('.dashboard').addClass "hidden"
    show: () -> $('.dashboard').removeClass "hidden"
