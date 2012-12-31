(function() {

  define(["jquery", "d3"], function($, d3) {
    var ResponseTimeScatterPlot;
    return ResponseTimeScatterPlot = (function() {

      function ResponseTimeScatterPlot(canvas, url) {
        var height, width;
        height = canvas.height();
        width = canvas.width();
        $.getJSON(url, function(data) {
          var graph, x, xAxis, y, yAxis;
          console.log(data);
          x = d3.scale.linear().domain([
            d3.min(data, function(d) {
              return d.timestamp;
            }), d3.max(data, function(d) {
              return d.timestamp;
            })
          ]).range([0, width]).nice();
          y = d3.scale.linear().domain([
            0, d3.max(data, function(d) {
              return d.responseTime;
            })
          ]).range([height, 0]).nice();
          xAxis = d3.svg.axis().scale(x);
          yAxis = d3.svg.axis().scale(y).orient("left").ticks(6);
          graph = d3.select(canvas[0]);
          graph.selectAll(".mark").data(data).enter().append("circle").attr("class", "mark").attr("cx", function(d, i) {
            return x(d.timestamp);
          }).attr("cy", function(d, i) {
            return y(d.responseTime);
          }).attr("r", function(d, i) {
            return 2.5;
          });
          graph.append("g").attr("class", "axis").call(yAxis);
          return graph.append("g").attr("class", "axis").attr("transform", "translate(0, " + height + ")").call(xAxis);
        });
      }

      return ResponseTimeScatterPlot;

    })();
  });

}).call(this);
