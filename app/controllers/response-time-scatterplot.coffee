define ["jquery", "d3"], ($, d3) ->

  class ResponseTimeScatterPlot
    constructor: (canvas, url, markSize) ->
      height         = canvas.height()
      width          = canvas.width()
      $.getJSON url, (data) ->
        sampleFormatter = (d) ->
          d.elapsedTimeStr = d.elapsedTime.toFixed 3
          d

        $(".tops .response-time").render data.map(sampleFormatter), label: href: -> @label

        x = d3.scale.linear()
          .domain([d3.min(data, (d) -> d.timeSinceStart), d3.max(data, (d) -> d.timeSinceStart)])
          .range([0, width])
          .nice()

        y = d3.scale.linear()
          .domain([0, d3.max data.map((d) -> d.elapsedTime).concat [5]])
          .range([height, 0])
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

        graph = d3.select(canvas[0])

        graph.selectAll(".mark")
          .data(data)
        .enter()
          .append("circle")
          .attr("class", (d) -> if d.failed then "mark failed" else "mark passed")
          .attr("cx", (d) -> x(d.timeSinceStart))
          .attr("cy", (d) -> y(d.elapsedTime))
          .attr("r", markSize)
          .on("mouseover", showSample)

        graph.append("g")
          .attr("class", "axis")
          .call(yAxis)

        graph.append("g")
          .attr("class", "axis")
          .attr("transform", "translate(0, #{height})")
          .call(xAxis)
