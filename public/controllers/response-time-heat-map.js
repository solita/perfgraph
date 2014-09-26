(function() {
  define(["jquery", "d3", "lodash"], function($, d3, _) {
    var ResponseTimeHeatMap;
    return ResponseTimeHeatMap = (function() {
      function ResponseTimeHeatMap(elem, url, historyLength) {
        this.elem = elem;
        this.url = url;
        this.historyLength = historyLength;
        this.height = this.elem.height();
        this.width = this.elem.width();
      }

      ResponseTimeHeatMap.prototype.setHistoryLength = function(historyLength) {
        return this.historyLength = historyLength;
      };

      ResponseTimeHeatMap.prototype.update = function() {
        return $.getJSON("" + this.url + "/" + this.historyLength, (function(_this) {
          return function(data) {
            var buildNumbers, firstBuild, graph, isBuildNumVisible, labels, lastBuild, maxTime, showLabel, tiles, x, xAxis, y, yAxis, z, _i, _ref, _results;
            lastBuild = d3.max(data.buckets, function(d) {
              return d.build;
            });
            firstBuild = d3.min(data.buckets, function(d) {
              return d.build;
            });
            maxTime = d3.max(data.buckets, function(d) {
              return d.bucket;
            });
            buildNumbers = Object.keys(_.groupBy(data.buckets, 'build'));
            buildNumbers = _.sortBy(buildNumbers, 'build');
            buildNumbers = _.map(buildNumbers, function(s) {
              return parseInt(s);
            });
            isBuildNumVisible = function(build, numUnderMouse) {
              return buildNumbers.length < 10 || (build === firstBuild || build === lastBuild || build === numUnderMouse);
            };
            x = d3.scale.ordinal().domain((function() {
              _results = [];
              for (var _i = 0, _ref = buildNumbers.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; 0 <= _ref ? _i++ : _i--){ _results.push(_i); }
              return _results;
            }).apply(this)).rangeBands([0, _this.width], 0.1, 0.05);
            y = d3.scale.linear().domain([0, Math.max(maxTime, 10)]).range([_this.height, 0]).nice();
            z = d3.scale.sqrt().domain([
              0, d3.max(data.buckets, function(d) {
                return d.count;
              })
            ]).range(["lightblue", "black"]);
            xAxis = d3.svg.axis().scale(x).tickValues(buildNumbers).tickSize(0);
            yAxis = d3.svg.axis().scale(y).orient("left").ticks(3).tickSize(3);
            graph = d3.select(_this.elem[0]);
            graph.selectAll(".axis").remove();
            graph.append("g").attr("class", "y axis").call(yAxis);
            graph.select(".y.axis").append("text").attr("class", "y label").attr("text-anchor", "end").attr("y", -36).attr("dy", ".75em").attr("transform", "rotate(-90)").text("response time [s]");
            graph.append("g").attr("class", "x axis").attr("transform", "translate(0, " + _this.height + ")").call(xAxis).selectAll("text").attr("class", "build").classed("hidden", function(build) {
              return !isBuildNumVisible(build, 0);
            });
            graph.select(".x.axis").append("text").attr("class", "x label").attr("text-anchor", "end").attr("x", _this.width).attr("y", 20).text("build #");
            labels = graph.selectAll(".x.axis .build");
            showLabel = function(d) {
              return labels.classed("hidden", function(build) {
                return !isBuildNumVisible(build, d.build);
              });
            };
            tiles = graph.selectAll(".tile").data(data.buckets).on("mouseover", showLabel).attr("x", function(d) {
              return x(_.indexOf(buildNumbers, d.build));
            }).attr("y", function(d) {
              return y(d.bucket);
            }).attr("width", function(d) {
              return x.rangeBand();
            }).attr("height", function(d) {
              return y(d.bucket) - y(d.bucket + data.bucketSize);
            }).style("fill", function(d) {
              return z(d.count);
            }).on("click", function(d) {
              return page("/reports/" + data.project + "/" + data.testCase + "/" + d.build);
            });
            tiles.enter().append("rect").attr("class", "tile").on("mouseover", showLabel).attr("x", function(d) {
              return x(_.indexOf(buildNumbers, d.build));
            }).attr("y", function(d) {
              return y(d.bucket);
            }).attr("width", function(d) {
              return x.rangeBand();
            }).attr("height", function(d) {
              return y(d.bucket) - y(d.bucket + data.bucketSize);
            }).style("fill", function(d) {
              return z(d.count);
            }).on("click", function(d) {
              return page("/reports/" + data.project + "/" + data.testCase + "/" + d.build);
            });
            return tiles.exit().remove();
          };
        })(this));
      };

      return ResponseTimeHeatMap;

    })();
  });

}).call(this);
