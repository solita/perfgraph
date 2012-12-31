define ["jquery",
        "d3",
        "q"], ($, d3, q) ->

  class ReportController
    constructor: (@elem) ->
      # @lhResponseTime = new ResponseTimeGraph @elem.find(".graph.response-time"), "/response-time/lh", [23]
      # @lhErrors = new ErrorGraph @elem.find(".graph.error-percentage"), [13]

    hide: () -> @elem.addClass "hidden"
    show: (testCase, build) ->
      @elem.removeClass "hidden"
