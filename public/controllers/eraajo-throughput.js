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
          var graph, line, x, xAxis, y, yAxis, z;
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
          graph.selectAll(".line").data(data).enter().append("path").attr("class", "line").attr("d", line).style("stroke", function(d) {
            return z(d[0].testCaseId);
          });
          graph.append("g").attr("class", "axis").call(yAxis);
          return graph.append("g").attr("class", "axis").attr("transform", "translate(0, " + _this.height + ")").call(xAxis);
        });
      };

      return EraajoThroughput;

    })();
  });

}).call(this);
