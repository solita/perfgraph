define ["jquery", "d3"], ($, d3) ->

  class ErrorGraph
    constructor: (canvas, currentBuild) ->
      height = canvas.height()
      width  = canvas.width()
      data   = ({x: n, y: 10 * Math.random()} for n in [0..29])

      currentBuild ||= []

      x = d3.scale.linear()
        .domain([0, data.length])
        .range([0, width])

      y = d3.scale.sqrt()
        .domain([0, 100])
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

      graph = d3.select(canvas[0])

      line = d3.svg.line()
        .x((d) -> x(d.x))
        .y((d) -> y(d.y))

      graph.selectAll(".current-build")
        .data(currentBuild)
        .enter()
        .append("path")
        .attr("d", (currentBuild, i) -> line([{x: 4, y: 0}, {x: 4, y: -0.25}]))
        .attr("class", "current-build")

      graph.append("path")
        .attr("d", line(data))

      graph.append("g")
        .attr("class", "axis")
        .call(yAxis)

      graph.append("g")
        .attr("class", "axis")
        .attr("transform", "translate(0, #{height})")
        .call(xAxis)
