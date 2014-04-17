(function() {
  define(["jquery", "d3"], function($, d3) {
    var ErrorGraph;
    return ErrorGraph = (function() {
      function ErrorGraph(canvas, currentBuild) {
        var data, graph, height, line, n, width, x, xAxis, y, yAxis;
        height = canvas.height();
        width = canvas.width();
        data = (function() {
          var _i, _results;
          _results = [];
          for (n = _i = 0; _i <= 29; n = ++_i) {
            _results.push({
              x: n,
              y: 10 * Math.random()
            });
          }
          return _results;
        })();
        currentBuild || (currentBuild = []);
        x = d3.scale.linear().domain([0, data.length]).range([0, width]);
        y = d3.scale.sqrt().domain([0, 100]).range([height, 0]);
        xAxis = d3.svg.axis().scale(x).ticks(0).tickSize(0);
        yAxis = d3.svg.axis().scale(y).orient("left").ticks(5).tickSize(3);
        graph = d3.select(canvas[0]);
        line = d3.svg.line().x(function(d) {
          return x(d.x);
        }).y(function(d) {
          return y(d.y);
        });
        graph.selectAll(".current-build").data(currentBuild).enter().append("path").attr("d", function(currentBuild, i) {
          return line([
            {
              x: 4,
              y: 0
            }, {
              x: 4,
              y: -0.25
            }
          ]);
        }).attr("class", "current-build");
        graph.append("path").attr("d", line(data));
        graph.append("g").attr("class", "axis").call(yAxis);
        graph.append("g").attr("class", "axis").attr("transform", "translate(0, " + height + ")").call(xAxis);
      }

      return ErrorGraph;

    })();
  });

}).call(this);
