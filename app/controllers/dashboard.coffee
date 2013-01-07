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

      @elem.find(".graph").width(width).height(height)

      @lhResponseTime = new ResponseTimeHeatMap @elem.find(".lh.response-time"), "/response-time-trend/lh"
      @rtResponseTime = new ResponseTimeHeatMap @elem.find(".rt.response-time"), "/response-time-trend/rt"
      @voResponseTime = new ResponseTimeHeatMap @elem.find(".vo.response-time"), "/response-time-trend/vo"

      @lhScatterPlot = new ResponseTimeScatterPlot @elem.find(".lh.response-time.scatter-plot"), "/reports/lh/latest.json", 0.5
      @rtScatterPlot = new ResponseTimeScatterPlot @elem.find(".rt.response-time.scatter-plot"), "/reports/rt/latest.json", 0.5
      @voScatterPlot = new ResponseTimeScatterPlot @elem.find(".vo.response-time.scatter-plot"), "/reports/vo/latest.json", 0.5

    hide: () -> $('.dashboard').addClass "hidden"
    show: () -> $('.dashboard').removeClass "hidden"
