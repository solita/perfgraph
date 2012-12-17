(function() {

  define(["jquery", "d3", "q"], function($, d3, q) {
    var ResponseTimeGraph;
    return ResponseTimeGraph = (function() {

      function ResponseTimeGraph(canvas, currentBuild) {
        var data, height, width;
        currentBuild || (currentBuild = []);
        height = canvas.height();
        width = canvas.width();
        data = q.when($.getJSON("/response-time/lh"));
        data.then(function(data) {
          var graph, line, x, xAxis, y, yAxis;
          x = d3.scale.linear().domain([0, data.length + 1]).range([0, width]);
          y = d3.scale.sqrt().domain([0, 30]).range([height, 0]);
          xAxis = d3.svg.axis().scale(x).ticks(0).tickSize(0);
          yAxis = d3.svg.axis().scale(y).orient("left").ticks(3).tickSize(3);
          graph = d3.select(canvas[0]);
          line = d3.svg.line().x(function(d) {
            return x(d[0]);
          }).y(function(d) {
            return y(d[1]);
          });
          graph.selectAll(".current-build").data(currentBuild).enter().append("path").attr("d", function(currentBuild, i) {
            return line([[currentBuild, 0], [currentBuild, -1.5]]);
          }).attr("class", "current-build");
          graph.selectAll(".boxplot.min-max").data(data).enter().append("path").attr("d", function(d, i) {
            console.log(i);
            return line([[i, d.min], [i, d.max]]);
          }).attr("class", "boxplot min-max");
          graph.selectAll(".boxplot.percentiles").data(data).enter().append("path").attr("d", function(d, i) {
            return line([[i, d.lowerPercentile], [i, d.upperPercentile]]);
          }).attr("class", "boxplot percentiles").on("click", function(d) {
            return page("/reports/" + d.build);
          });
          graph.selectAll(".boxplot.median").data(data).enter().append("path").attr("d", function(d, i) {
            return line([[i - 0.2, d.median], [i + 0.2, d.median]]);
          }).attr("class", "boxplot median");
          graph.append("g").attr("class", "axis").call(yAxis);
          return graph.append("g").attr("class", "axis").attr("transform", "translate(0, " + height + ")").call(xAxis);
        });
      }

      return ResponseTimeGraph;

    })();
  });

}).call(this);
