define ["jquery", "d3", "controllers/response-time-scatterplot"], ($, d3, ResponseTimeScatterPlot) ->

  class ReportController
    constructor: (@elem) ->
      @scatterPlot = new ResponseTimeScatterPlot @elem.find(".graph"), "", 2

    hide: () -> @elem.addClass "hidden"
    show: (testCase, build) ->
      @elem.find(".testCaseId").text testCase
      @elem.find(".build").text build
      @elem.removeClass "hidden"
      @scatterPlot.update("/reports/#{testCase}/#{build}.json")
