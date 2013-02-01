(function() {

  define(["jquery", "d3", "lodash", "transparency"], function($, d3, _) {
    var ThroughputLine;
    return ThroughputLine = (function() {

      function ThroughputLine(elem, url, updateCallback) {
        this.elem = elem;
        this.url = url;
        this.updateCallback = updateCallback;
        this.width = this.elem.width();
        this.height = this.elem.height();
      }

      ThroughputLine.prototype.update = function() {
        var _this = this;
        return $.getJSON(this.url, function(data) {
          var flatData, graph, line, lines, x, xAxis, y, yAxis, z;
          flatData = _.flatten(data);
          x = d3.scale.linear().domain(d3.extent(flatData, function(d) {
            return d.build;
          })).range([0, _this.width]).nice();
          y = d3.scale.sqrt().domain([
            0, d3.max(flatData, function(d) {
              return d.throughput;
            })
          ]).range([_this.height, 0]).nice();
          z = d3.scale.category10().domain(flatData.map(function(d) {
            return d.testCaseId;
          }));
          if (_this.updateCallback) {
            _this.updateCallback(data, z);
          }
          xAxis = d3.svg.axis().scale(x).tickSize(0).tickValues(flatData.map(function(d) {
            return d.build;
          })).tickFormat(d3.format(",.0f"));
          yAxis = d3.svg.axis().scale(y).orient("left").ticks(5).tickSize(3);
          graph = d3.select(_this.elem[0]);
          line = d3.svg.line().x(function(d) {
            return x(d.build);
          }).y(function(d) {
            return y(d.throughput);
          });
          lines = graph.selectAll(".line").data(data).attr("d", line).style("stroke", function(d) {
            return z(d[0].testCaseId);
          });
          lines.enter().append("path").attr("class", "line").attr("d", line).style("stroke", function(d) {
            return z(d[0].testCaseId);
          });
          lines.exit().remove();
          graph.selectAll(".axis").remove();
          graph.append("g").attr("class", "y axis").call(yAxis).append("text").attr("class", "y label").attr("text-anchor", "end").attr("y", -36).attr("dy", ".75em").attr("transform", "rotate(-90)").text("throughput [1/s]");
          return graph.append("g").attr("class", "x axis").attr("transform", "translate(0, " + _this.height + ")").call(xAxis).append("text").attr("class", "x label").attr("text-anchor", "end").attr("x", _this.width + 7).attr("y", 20).text("build #");
        });
      };

      return ThroughputLine;

    })();
  });

}).call(this);
