(function() {

  define(["jquery", "d3", "lodash"], function($, d3, _) {
    var EraajoThroughput;
    return EraajoThroughput = (function() {

      function EraajoThroughput(elem, url) {
        this.elem = elem;
        this.url = url;
        this.width = this.elem.width();
        this.height = this.elem.height();
      }

      EraajoThroughput.prototype.update = function() {
        var _this = this;
        return $.getJSON(this.url, function(data) {
          var graph, line, lines, x, xAxis, y, yAxis, z;
          x = d3.scale.linear().domain(d3.extent(_.flatten(data), function(d) {
            return d.build;
          })).range([0, _this.width]).nice();
          y = d3.scale.linear().domain(d3.extent(_.flatten(data), function(d) {
            return d.throughput;
          })).range([_this.height, 0]).nice();
          z = d3.scale.category10().domain(_.flatten(data).map(function(d) {
            return d.testCaseId;
          }));
          xAxis = d3.svg.axis().scale(x).ticks(0).tickSize(0);
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

      return EraajoThroughput;

    })();
  });

}).call(this);
