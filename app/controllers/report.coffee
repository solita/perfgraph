define ["jquery", "d3"], ($, d3) ->

  class ReportController
    constructor: (@elem) ->
      height = $(window).height() * 0.5
      width  = $(window).width() * 0.9
      @elem.find(".graph")
        .width(width)
        .height(height)

    hide: () -> @elem.addClass "hidden"
    show: (testCase, build) ->
      @elem.removeClass "hidden"
      $.getJSON "/reports/#{testCase}/#{build}.json", (data) ->
        #console.log data

