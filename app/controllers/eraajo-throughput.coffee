define ["jquery", "d3", "lodash"], ($, d3, _) ->

  class EraajoThroughput
    constructor: (@elem, @url) ->
      @width  = @elem.width()
      @height = @elem.height()

    update: ->
      $.getJSON @url, (data) =>
        x = d3.scale.linear()
          .domain(d3.extent _.flatten(data), (d) -> d.build)
          .range([0, @width])
          .nice()

        y = d3.scale.linear()
          .domain(d3.extent _.flatten(data), (d) -> d.throughput)
          .range([@height, 0])
          .nice()

        z = d3.scale.category10()
          .domain(_.flatten(data).map (d) -> d.testCaseId)

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
          .x((d) -> x(d.build))
          .y((d) -> y(d.throughput))

        graph.selectAll(".line")
            .data(data)
          .enter().append("path")
            .attr("class", "line")
            .attr("d", line)
            .style("stroke", (d) -> z(d[0].testCaseId))

        graph.append("g")
          .attr("class", "axis")
          .call(yAxis)

        graph.append("g")
          .attr("class", "axis")
          .attr("transform", "translate(0, #{@height})")
          .call(xAxis)
