define ["jquery", "d3"], ($, d3) ->

  class ResponseTimeScatterPlot
    constructor: (canvas, url) ->
      sample = $('.report .sample')

      height         = canvas.height()
      width          = canvas.width()
      $.getJSON url, (data) ->
        x = d3.scale.linear()
          .domain([d3.min(data, (d) -> d.timeStamp), d3.max(data, (d) -> d.timeStamp) + 5])
          .range([0, width])

        y = d3.scale.linear()
          .domain([0, d3.max(data, (d) -> d.elapsedTime)])
          .range([height, 0])
          .nice()

        showSample = (d) ->
          sample.find('.elapsedTime').text "#{d.elapsedTime} s"
          sample.find('.responseCode').text d.responseCode
          sample.find('.bytes').text "#{d.bytes} B"
          sample.find('.label')
            .text(d.label)
            .attr("href", d.label)

        xAxis = d3.svg.axis()
          .scale(x)

        yAxis = d3.svg.axis()
          .scale(y)
          .orient("left")
          .ticks(6)

        graph = d3.select(canvas[0])

        graph.selectAll(".mark")
          .data(data)
        .enter()
          .append("circle")
          .attr("class", "mark")
          .attr("cx", (d, i) -> x(d.timeStamp))
          .attr("cy", (d, i) -> y(d.elapsedTime))
          .attr("r", 2.5)
          .on("mouseover", showSample)

        graph.append("g")
          .attr("class", "axis")
          .call(yAxis)

        graph.append("g")
          .attr("class", "axis")
          .attr("transform", "translate(0, #{height})")
          .call(xAxis)
