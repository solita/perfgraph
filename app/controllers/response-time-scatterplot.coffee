define ["jquery", "d3", "moment"], ($, d3, moment) ->

  class ResponseTimeScatterPlot
    constructor: (@elem, @url, @markSize) ->

    update: (url = @url) ->
      @height = @elem.height()
      @width  = @elem.width()

      $.getJSON url, (data) =>
        sampleFormatter = (d) ->
          d.elapsedTimeStr = d.elapsedTime.toFixed 3
          d

        @elem.find(".tops .response-time").render data.samples.map(sampleFormatter), label: href: -> @label

        @elem.find(".testCaseId").text url

        x = d3.scale.linear()
          .domain([d3.min(data.samples, (d) -> d.timeSinceStart), d3.max(data.samples, (d) -> d.timeSinceStart)])
          .range([0, @width])
          .nice()

        y = d3.scale.sqrt()
          .domain([0, Math.max(data.maxElapsedTimeInBuild)])
          .range([@height, 0])
          .nice()

        sample = $('.report .sample')

        showSample = (d) ->
          date = moment.unix(d.timeStamp).format "D.M.YYYY HH:mm:ss"
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

        graph.selectAll(".axis").remove()

        graph
          .append("g")
          .attr("class", "y axis")
          .call(yAxis)

        graph.select(".y.axis")
          .append("text")
          .attr("class", "y label")
          .attr("text-anchor", "end")
          .attr("y", -36)
          .attr("dy", ".75em")
          .attr("transform", "rotate(-90)")
          .text("response time [s]")

        graph.append("g")
          .attr("class", "x axis")
          .attr("transform", "translate(0, #{@height})")
          .call(xAxis)

        graph.select(".x.axis")
          .append("text")
          .attr("class", "x label")
          .attr("text-anchor", "end")
          .attr("x", @width + 13)
          .attr("y", 27)
          .text("request time [s]")

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


