define ["jquery",
        "controllers/error-graph",
        "controllers/response-time-graph"], ($, ErrorGraph, ResponseTimeGraph) ->

  class ReportController
    constructor: (@elem) ->
      @lhResponseTime = new ResponseTimeGraph @elem.find(".graph.response-time"), [23]
      @lhErrors = new ErrorGraph @elem.find(".graph.error-percentage"), [13]

    hide: () -> @elem.addClass "hidden"
    show: () -> @elem.removeClass "hidden"
