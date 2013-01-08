define ["jquery", "d3"], ($, d3) ->

  class ResponseTimeScatterPlot
    constructor: (@elem, @url, @markSize) ->
      @height = @elem.height()
      @width  = @elem.width()

    update: () ->
      $.getJSON @url, (data) =>
        data =
          samples: data
          maxElapsedTimeInBuild: 7

        sampleFormatter = (d) ->
          d.elapsedTimeStr = d.elapsedTime.toFixed 3
          d

        $(".tops .response-time").render data.samples.map(sampleFormatter), label: href: -> @label

        x = d3.scale.linear()
          .domain([d3.min(data.samples, (d) -> d.timeSinceStart), d3.max(data.samples, (d) -> d.timeSinceStart)])
          .range([0, @width])
          .nice()

        y = d3.scale.sqrt()
          .domain([0, Math.max(data.maxElapsedTimeInBuild, 5)])
          .range([@height, 0])
          .nice()

        sample = $('.report .sample')

        showSample = (d) ->
          date = new Date(d.timeStamp*1000)
          sample.find('.timeStamp').text "#{date}"
          sample.find('.elapsedTime').text "#{d.elapsedTimeStr} s"
          sample.find('.responseCode').text d.responseCode
          sample.find('.bytes').text "#{d.bytes} B"
          sample.find('.label')
            .text(d.label)
            .attr("href", d.label)

        xAxis = d3.svg.axis()
          .scale(x)
          .ticks(6)

        yAxis = d3.svg.axis()
          .scale(y)
          .orient("left")
          .ticks(6)

        graph = d3.select(@elem[0])

        marks = graph.selectAll(".mark").data(data.samples)
          .attr("class", (d) -> if d.failed then "mark failed" else "mark passed")
          .attr("cx", (d) -> x(d.timeSinceStart))
          .attr("cy", (d) -> y(d.elapsedTime))

        marks.enter()
          .append("circle")
          .attr("class", (d) -> if d.failed then "mark failed" else "mark passed")
          .attr("cx", (d) -> x(d.timeSinceStart))
          .attr("cy", (d) -> y(d.elapsedTime))
          .attr("r", @markSize)
          .on("mouseover", showSample)

        marks.exit().remove()

        graph.selectAll(".axis").remove()

        graph
          .append("g")
          .attr("class", "axis")
          .call(yAxis)

        graph.append("g")
          .attr("class", "axis")
          .attr("transform", "translate(0, #{@height})")
          .call(xAxis)
