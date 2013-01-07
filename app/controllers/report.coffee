define ["jquery", "d3", "controllers/response-time-scatterplot"], ($, d3, ResponseTimeScatterPlot) ->

  class ReportController
    constructor: (@elem) ->
      height = $(window).height() * 0.5
      width  = $(window).width() * 0.9
      @graph = @elem.find(".graph")
        .width(width)
        .height(height)

    hide: () -> @elem.addClass "hidden"
    show: (testCase, build) ->
      @elem.removeClass "hidden"
      @graph.empty()
      scatterPlot = new ResponseTimeScatterPlot @graph, "/reports/#{testCase}/#{build}.json", 2
