define ["jquery",
        "controllers/error-graph",
        "controllers/response-time-graph",
        "controllers/response-time-heat-map"], ($, ErrorGraph, ResponseTimeGraph, ResponseTimeHeatMap) ->

  class DashboardController
    constructor: (@elem) ->
      # Set dimensions for the graphs
      columnCount = @elem.find("tr:first-child td").length
      rowCount    = @elem.find("tr").length
      height      = $(window).height() * 0.7 / (rowCount - 1)
      width       = $(window).width() * 0.7 / (columnCount - 1)

      $(".graph").width(width).height(height)

      @lhResponseTime = new ResponseTimeHeatMap @elem.find(".lh.response-time"), "/response-time-raw/lh"
      @rtResponseTime = new ResponseTimeHeatMap @elem.find(".rt.response-time"), "/response-time-raw/rt"
      @voResponseTime = new ResponseTimeHeatMap @elem.find(".vo.response-time"), "/response-time-raw/vo"

      @lhErrors = new ErrorGraph @elem.find(".lh.error-percentage")
      @rtErrors = new ErrorGraph @elem.find(".rt.error-percentage")
      @voErrors = new ErrorGraph @elem.find(".vo.error-percentage")

    hide: () -> $('.dashboard').addClass "hidden"
    show: () -> $('.dashboard').removeClass "hidden"
