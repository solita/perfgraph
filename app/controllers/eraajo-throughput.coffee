define ["jquery", "d3"], ($, d3) ->

  class EraajoThroughput
    constructor: (@elem, @url) ->
      height = @elem.height()
      data   = ({x: n, y: 10 * Math.random()} for n in [0..29])

      x = d3.scale.linear()
        .domain([0, data.length])
        .range([0, @elem.width()])

      y = d3.scale.linear()
        .domain([0, 15])
        .range([height, 0])

      xAxis = d3.svg.axis()
        .scale(x)
        .ticks(0)
        .tickSize(0)

      yAxis = d3.svg.axis()
        .scale(y)
        .orient("left")
        .ticks(5)
        .tickSize(3)

      graph = d3.select(@elem[0])

      line = d3.svg.line()
        .x((d) -> x(d.x))
        .y((d) -> y(d.y))

      graph.append("path")
        .attr("class", "error-percentage")
        .attr("d", line(data))

      graph.append("g")
        .attr("class", "axis")
        .call(yAxis)

      graph.append("g")
        .attr("class", "axis")
        .attr("transform", "translate(0, #{height})")
        .call(xAxis)
