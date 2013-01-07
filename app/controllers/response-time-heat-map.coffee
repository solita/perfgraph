define ["jquery", "d3"], ($, d3) ->

  class ResponseTimeHeatMap
    constructor: (canvas, url) ->
      height = canvas.height()
      width  = canvas.width()
      $.getJSON url, (data) ->
        lastBuild  = d3.max(data, (d) -> d.build)
        firstBuild = d3.min(data, (d) -> d.build)

        x = d3.scale.ordinal()
          .domain([firstBuild..lastBuild])
          .rangeBands([0, width], 0.1)

        y = d3.scale.linear()
          .domain([0, d3.max(data, (d) -> d.bucket)])
          .range([height, 0])
          .nice()

        z = d3.scale.linear()
          .domain([0, d3.max data, (d) -> d.count])
          .range(["lightblue", "black"])

        xAxis = d3.svg.axis()
          .scale(x)
          .tickSize(0)

        yAxis = d3.svg.axis()
          .scale(y)
          .orient("left")
          .ticks(3)
          .tickSize(3)

        graph = d3.select(canvas[0])

        graph.append("g")
          .attr("class", "y axis")
          .call(yAxis)

        graph.append("g")
          .attr("class", "x axis")
          .attr("transform", "translate(0, #{height})")
          .call(xAxis)
          .selectAll("text")
          .classed("hidden", (build) -> [firstBuild, lastBuild].indexOf(build) < 0)

        labels    = graph.selectAll(".x.axis text")
        showLabel = (d) ->
          labels.classed("hidden", (build) ->
            [firstBuild, lastBuild, d.build].indexOf(build) < 0)

        graph.selectAll(".tile")
          .data(data)
        .enter()
          .append("rect")
          .attr("class", "tile")
          .attr("x",      (d) -> x(d.build))
          .attr("y",      (d) -> y(d.bucket))
          .attr("width",  (d) -> x.rangeBand())
          .attr("height", (d) -> y(d.bucket) - y(d.bucket + d.bucketSize))
          .style("fill",  (d) -> z(d.count))
          .on("mouseover", showLabel)
          .on("click",    (d) -> page "/reports/#{d.testCase}/#{d.build}")
