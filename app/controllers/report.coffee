define ["jquery", "d3", "controllers/response-time-scatterplot"], ($, d3, ResponseTimeScatterPlot) ->

  class ReportController

    sampleFormatter = (d) ->
      d.elapsedTimeStr = d.elapsedTime.toFixed 3
      d

    updateTopsList = (data) ->
      $(".tops .response-time").render data.samples.map(sampleFormatter),
        label: href: -> @label

    constructor: (@elem) ->
      @scatterPlot = new ResponseTimeScatterPlot @elem.find(".graph"), "", 2

    hide: () -> @elem.addClass "hidden"
    show: (project, testCase, build) ->
      @elem.find(".testCaseId").text testCase
      @elem.find(".build").text build
      @elem.removeClass "hidden"
      @scatterPlot.update("/reports/#{project}/#{testCase}/#{build}.json", updateTopsList)
