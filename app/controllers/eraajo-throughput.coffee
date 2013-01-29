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

        lines = graph.selectAll(".line").data(data)
          .attr("d", line)
          .style("stroke", (d) -> z(d[0].testCaseId))

        lines.enter()
          .append("path")
          .attr("class", "line")
          .attr("d", line)
          .style("stroke", (d) -> z(d[0].testCaseId))

        lines.exit().remove()

        graph.append("g")
          .attr("class", "axis")
          .call(yAxis)

        graph.append("g")
          .attr("class", "axis")
          .attr("transform", "translate(0, #{@height})")
          .call(xAxis)

        #Axis labels
        graph.selectAll(".x.label").remove()
        graph.append("text")
          .attr("class", "x label")
          .attr("text-anchor", "end")
          .attr("x", @width + 7)
          .attr("y", @height + 20)
          .text("build #")

        graph.selectAll(".y.label").remove()
        graph.append("text")
          .attr("class", "y label")
          .attr("text-anchor", "end")
          .attr("y", -36)
          .attr("dy", ".75em")
          .attr("transform", "rotate(-90)")
          .text("throughput [1/s]")
