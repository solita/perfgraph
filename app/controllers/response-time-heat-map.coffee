define ["jquery", "d3"], ($, d3) ->

  class ResponseTimeHeatMap
    constructor: (canvas, url) ->
      height         = canvas.height()
      width          = canvas.width()
      $.getJSON url, (data) ->
        x = d3.scale.linear()
          .domain([d3.min(data, (d) -> d.build), d3.max(data, (d) -> d.build) + 1])
          .range([0, width])
          .nice()

        y = d3.scale.linear()
          .domain([0, d3.max(data, (d) -> d.bucket + 5)])
          .range([height, 0])
          .nice()

        z = d3.scale.linear()
          .domain([0, d3.max data, (d) -> d.count])
          .range(["lightblue", "black"])

        xAxis = d3.svg.axis()
          .scale(x)
          .ticks(0)
          .tickSize(0)

        yAxis = d3.svg.axis()
          .scale(y)
          .orient("left")
          .ticks(3)
          .tickSize(3)

        graph = d3.select(canvas[0])

        graph.selectAll(".tile")
          .data(data)
        .enter()
          .append("rect")
          .attr("class", "tile")
          .attr("x", (d, i) -> x(d.build))
          .attr("y", (d, i) -> y(d.bucket))
          .attr("width", (d, i) -> 10)
          .attr("height", (d, i) -> y(d.bucket) - y(d.bucket + d.bucketSize))
          .style("fill", (d) -> z(d.count))
          .on("click", (d) -> page "/reports/#{d.testCase}/#{d.build}")

        graph.append("g")
          .attr("class", "axis")
          .call(yAxis)

        graph.append("g")
          .attr("class", "axis")
          .attr("transform", "translate(0, #{height})")
          .call(xAxis)
