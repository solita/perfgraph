define ["jquery", "d3", "lodash", "transparency"], ($, d3, _) ->

  class ThroughputLine
    constructor: (@elem, @api, @updateCallback, @historyLength) ->
      @width  = @elem.width()
      @height = @elem.height()

    setHistoryLength: (historyLength) ->
      @historyLength = historyLength

    update: ->
      $.getJSON "/throughput/#{@api}/#{@historyLength}", (data) =>
        flatData = _.flatten(data)
        allBuildNumbers = _.pluck flatData, "build"
        buildNumbers = _.uniq allBuildNumbers
        # We must sort here, since the flatData is groupped and not all
        # builds are present in every group.
        buildNumbers = _.sortBy buildNumbers, (a) -> parseInt a  

        x = d3.scale.linear()
          .domain([0, buildNumbers.length-1])
          .range([0, @width])
          .nice()

        y = d3.scale.linear()
          .domain([0, d3.max flatData, (d) -> d.throughput])
          .range([@height, 0])
          .nice()

        z = d3.scale.category10()
          .domain(flatData.map (d) -> d.testCaseId)

        @updateCallback(data, z) if @updateCallback

        xAxis = d3.svg.axis()
          .scale(x)
          .tickSize(0)
          .tickValues([0 .. buildNumbers.length-1])
          .tickFormat((x) -> buildNumbers[x])

        yAxis = d3.svg.axis()
          .scale(y)
          .orient("left")
          .ticks(5)
          .tickSize(3)

        graph = d3.select(@elem[0])

        line = d3.svg.line()
          .x((d) -> x(_.indexOf(buildNumbers, d.build)))
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

        graph.selectAll(".axis").remove()

        graph.append("g")
          .attr("class", "y axis")
          .call(yAxis)
          .append("text")
          .attr("class", "y label")
          .attr("text-anchor", "end")
          .attr("y", -36)
          .attr("dy", ".75em")
          .attr("transform", "rotate(-90)")
          .text("throughput [1/s]")

        graph.append("g")
          .attr("class", "x axis")
          .attr("transform", "translate(0, #{@height})")
          .call(xAxis)
          .append("text")
          .attr("class", "x label")
          .attr("text-anchor", "end")
          .attr("x", @width + 7)
          .attr("y", 20)
          .text("build #")
