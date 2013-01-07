(function() {

  define(["jquery", "d3"], function($, d3) {
    var ResponseTimeHeatMap;
    return ResponseTimeHeatMap = (function() {

      function ResponseTimeHeatMap(canvas, url) {
        var height, width;
        height = canvas.height();
        width = canvas.width();
        $.getJSON(url, function(data) {
          var graph, x, xAxis, y, yAxis, z;
          x = d3.scale.linear().domain([
            d3.min(data, function(d) {
              return d.build;
            }), d3.max(data, function(d) {
              return d.build;
            }) + 1
          ]).range([0, width]).nice();
          y = d3.scale.linear().domain([
            0, d3.max(data, function(d) {
              return d.bucket + 5;
            })
          ]).range([height, 0]).nice();
          z = d3.scale.linear().domain([
            0, d3.max(data, function(d) {
              return d.count;
            })
          ]).range(["lightblue", "black"]);
          xAxis = d3.svg.axis().scale(x).ticks(0).tickSize(0);
          yAxis = d3.svg.axis().scale(y).orient("left").ticks(3).tickSize(3);
          graph = d3.select(canvas[0]);
          graph.selectAll(".tile").data(data).enter().append("rect").attr("class", "tile").attr("x", function(d, i) {
            return x(d.build);
          }).attr("y", function(d, i) {
            return y(d.bucket);
          }).attr("width", function(d, i) {
            return 10;
          }).attr("height", function(d, i) {
            return y(d.bucket) - y(d.bucket + d.bucketSize);
          }).style("fill", function(d) {
            return z(d.count);
          }).on("click", function(d) {
            return page("/reports/" + d.testCase + "/" + d.build);
          });
          graph.append("g").attr("class", "axis").call(yAxis);
          return graph.append("g").attr("class", "axis").attr("transform", "translate(0, " + height + ")").call(xAxis);
        });
      }

      return ResponseTimeHeatMap;

    })();
  });

}).call(this);
