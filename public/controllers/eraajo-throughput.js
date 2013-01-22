(function() {

  define(["jquery", "d3"], function($, d3) {
    var EraajoThroughput;
    return EraajoThroughput = (function() {

      function EraajoThroughput(elem, url) {
        var data, graph, height, line, n, x, xAxis, y, yAxis;
        this.elem = elem;
        this.url = url;
        height = this.elem.height();
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
        x = d3.scale.linear().domain([0, data.length]).range([0, this.elem.width()]);
        y = d3.scale.linear().domain([0, 15]).range([height, 0]);
        xAxis = d3.svg.axis().scale(x).ticks(0).tickSize(0);
        yAxis = d3.svg.axis().scale(y).orient("left").ticks(5).tickSize(3);
        graph = d3.select(this.elem[0]);
        line = d3.svg.line().x(function(d) {
          return x(d.x);
        }).y(function(d) {
          return y(d.y);
        });
        graph.append("path").attr("class", "error-percentage").attr("d", line(data));
        graph.append("g").attr("class", "axis").call(yAxis);
        graph.append("g").attr("class", "axis").attr("transform", "translate(0, " + height + ")").call(xAxis);
      }

      return EraajoThroughput;

    })();
  });

}).call(this);
