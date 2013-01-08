(function() {

  define(["jquery", "d3"], function($, d3) {
    var ResponseTimeHeatMap;
    return ResponseTimeHeatMap = (function() {

      function ResponseTimeHeatMap(elem, url) {
        this.elem = elem;
        this.url = url;
        this.height = this.elem.height();
        this.width = this.elem.width();
      }

      ResponseTimeHeatMap.prototype.update = function() {
        var _this = this;
        return $.getJSON(this.url, function(data) {
          var firstBuild, graph, labels, lastBuild, showLabel, tiles, x, xAxis, y, yAxis, z, _i, _results;
          data = {
            samples: data,
            maxElapsedTimeInBuilds: 600
          };
          lastBuild = d3.max(data.samples, function(d) {
            return d.build;
          });
          firstBuild = d3.min(data.samples, function(d) {
            return d.build;
          });
          x = d3.scale.ordinal().domain((function() {
            _results = [];
            for (var _i = firstBuild; firstBuild <= lastBuild ? _i <= lastBuild : _i >= lastBuild; firstBuild <= lastBuild ? _i++ : _i--){ _results.push(_i); }
            return _results;
          }).apply(this)).rangeBands([0, _this.width], 0.1);
          y = d3.scale.sqrt().domain([0, Math.max(data.maxElapsedTimeInBuilds, 60)]).range([_this.height, 0]).nice();
          z = d3.scale.sqrt().domain([
            0, d3.max(data.samples, function(d) {
              return d.count;
            })
          ]).range(["lightblue", "black"]);
          xAxis = d3.svg.axis().scale(x).tickSize(0);
          yAxis = d3.svg.axis().scale(y).orient("left").ticks(3).tickSize(3);
          graph = d3.select(_this.elem[0]);
          graph.selectAll(".axis").remove();
          graph.append("g").attr("class", "y axis").call(yAxis);
          graph.append("g").attr("class", "x axis").attr("transform", "translate(0, " + _this.height + ")").call(xAxis).selectAll("text").classed("hidden", function(build) {
            return [firstBuild, lastBuild].indexOf(build) < 0;
          });
          labels = graph.selectAll(".x.axis text");
          showLabel = function(d) {
            return labels.classed("hidden", function(build) {
              return [firstBuild, lastBuild, d.build].indexOf(build) < 0;
            });
          };
          tiles = graph.selectAll(".tile").data(data.samples).attr("x", function(d) {
            return x(d.build);
          }).attr("y", function(d) {
            return y(d.bucket);
          }).attr("width", function(d) {
            return x.rangeBand();
          }).attr("height", function(d) {
            return y(d.bucket) - y(d.bucket + d.bucketSize);
          }).style("fill", function(d) {
            return z(d.count);
          }).on("click", function(d) {
            return page("/reports/" + d.testCase + "/" + d.build);
          });
          tiles.enter().append("rect").attr("class", "tile").on("mouseover", showLabel).attr("x", function(d) {
            return x(d.build);
          }).attr("y", function(d) {
            return y(d.bucket);
          }).attr("width", function(d) {
            return x.rangeBand();
          }).attr("height", function(d) {
            return y(d.bucket) - y(d.bucket + d.bucketSize);
          }).style("fill", function(d) {
            return z(d.count);
          }).on("click", function(d) {
            return page("/reports/" + d.testCase + "/" + d.build);
          });
          return tiles.exit().remove();
        });
      };

      return ResponseTimeHeatMap;

    })();
  });

}).call(this);
