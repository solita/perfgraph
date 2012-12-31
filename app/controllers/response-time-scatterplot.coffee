define ["jquery", "d3"], ($, d3) ->

  class ResponseTimeScatterPlot
    constructor: (canvas, url) ->
      height         = canvas.height()
      width          = canvas.width()
      $.getJSON url, (data) ->
        console.log data
        x = d3.scale.linear()
          .domain([d3.min(data, (d) -> d.timestamp), d3.max(data, (d) -> d.timestamp)])
          .range([0, width])
          .nice()

        y = d3.scale.linear()
          .domain([0, d3.max(data, (d) -> d.responseTime)])
          .range([height, 0])
          .nice()

        # z = d3.scale.linear()
        #   .domain([0, d3.max data, (d) -> d.count])
        #   .range(["lightblue", "black"])

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
          .attr("cx", (d, i) -> x(d.timestamp))
          .attr("cy", (d, i) -> y(d.responseTime))
          .attr("r", (d, i) -> 2.5)

        graph.append("g")
          .attr("class", "axis")
          .call(yAxis)

        graph.append("g")
          .attr("class", "axis")
          .attr("transform", "translate(0, #{height})")
          .call(xAxis)
