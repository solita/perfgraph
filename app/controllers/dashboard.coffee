define ["jquery",
        "controllers/error-graph",
        "controllers/response-time-graph"], ($, ErrorGraph, ResponseTimeGraph) ->

  class DashboardController
    constructor: (@elem) ->
      # Set dimensions for the graphs
      columnCount = @elem.find("tr:first-child td").length
      rowCount    = @elem.find("tr").length
      height      = $(window).height() * 0.7 / (rowCount - 1)
      width       = $(window).width() * 0.7 / (columnCount - 1)

      $(".graph").width(width).height(height)

      @lhResponseTime = new ResponseTimeGraph @elem.find(".lh.response-time"), "/response-time/lh"
      @rtResponseTime = new ResponseTimeGraph @elem.find(".rt.response-time"), "/response-time/rt"
      @voResponseTime = new ResponseTimeGraph @elem.find(".vo.response-time"), "/response-time/vo"

      @lhErrors = new ErrorGraph @elem.find(".lh.error-percentage")
      @rtErrors = new ErrorGraph @elem.find(".rt.error-percentage")
      @voErrors = new ErrorGraph @elem.find(".vo.error-percentage")

    hide: () -> $('.dashboard').addClass "hidden"
    show: () -> $('.dashboard').removeClass "hidden"
