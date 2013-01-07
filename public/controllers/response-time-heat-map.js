(function() {

  define(["jquery", "d3"], function($, d3) {
    var ResponseTimeHeatMap;
    return ResponseTimeHeatMap = (function() {

      function ResponseTimeHeatMap(canvas, url) {
        var height, width;
        height = canvas.height();
        width = canvas.width();
        $.getJSON(url, function(data) {
          var firstBuild, graph, labels, lastBuild, showLabel, x, xAxis, y, yAxis, z, _i, _results;
          lastBuild = d3.max(data, function(d) {
            return d.build;
          });
          firstBuild = d3.min(data, function(d) {
            return d.build;
          });
          x = d3.scale.ordinal().domain((function() {
            _results = [];
            for (var _i = firstBuild; firstBuild <= lastBuild ? _i <= lastBuild : _i >= lastBuild; firstBuild <= lastBuild ? _i++ : _i--){ _results.push(_i); }
            return _results;
          }).apply(this)).rangeBands([0, width], 0.1);
          y = d3.scale.linear().domain([
            0, d3.max(data, function(d) {
              return d.bucket;
            })
          ]).range([height, 0]).nice();
          z = d3.scale.linear().domain([
            0, d3.max(data, function(d) {
              return d.count;
            })
          ]).range(["lightblue", "black"]);
          xAxis = d3.svg.axis().scale(x).tickSize(0);
          yAxis = d3.svg.axis().scale(y).orient("left").ticks(3).tickSize(3);
          graph = d3.select(canvas[0]);
          graph.append("g").attr("class", "y axis").call(yAxis);
          graph.append("g").attr("class", "x axis").attr("transform", "translate(0, " + height + ")").call(xAxis).selectAll("text").classed("hidden", function(build) {
            return [firstBuild, lastBuild].indexOf(build) < 0;
          });
          labels = graph.selectAll(".x.axis text");
          showLabel = function(d) {
            return labels.classed("hidden", function(build) {
              return [firstBuild, lastBuild, d.build].indexOf(build) < 0;
            });
          };
          return graph.selectAll(".tile").data(data).enter().append("rect").attr("class", "tile").attr("x", function(d) {
            return x(d.build);
          }).attr("y", function(d) {
            return y(d.bucket);
          }).attr("width", function(d) {
            return x.rangeBand();
          }).attr("height", function(d) {
            return y(d.bucket) - y(d.bucket + d.bucketSize);
          }).style("fill", function(d) {
            return z(d.count);
          }).on("mouseover", showLabel).on("click", function(d) {
            return page("/reports/" + d.testCase + "/" + d.build);
          });
        });
      }

      return ResponseTimeHeatMap;

    })();
  });

}).call(this);
