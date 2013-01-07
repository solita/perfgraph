(function() {

  define(["jquery", "d3"], function($, d3) {
    var ResponseTimeScatterPlot;
    return ResponseTimeScatterPlot = (function() {

      function ResponseTimeScatterPlot(canvas, url) {
        var height, width;
        height = canvas.height();
        width = canvas.width();
        $.getJSON(url, function(data) {
          var graph, sample, sampleFormatter, showSample, x, xAxis, y, yAxis;
          sampleFormatter = function(d) {
            d.elapsedTimeStr = d.elapsedTime.toFixed(3);
            return d;
          };
          $(".tops .response-time").render(data.map(sampleFormatter), {
            label: {
              href: function() {
                return this.label;
              }
            }
          });
          x = d3.scale.linear().domain([
            d3.min(data, function(d) {
              return d.timeSinceStart;
            }), d3.max(data, function(d) {
              return d.timeSinceStart;
            }) + 5
          ]).range([0, width]);
          y = d3.scale.sqrt().domain([
            0, d3.max(data, function(d) {
              return d.elapsedTime;
            })
          ]).range([height, 0]).nice();
          sample = $('.report .sample');
          showSample = function(d) {
            var date;
            date = new Date(d.timeStamp * 1000);
            sample.find('.timeStamp').text("" + date);
            sample.find('.elapsedTime').text("" + d.elapsedTimeStr + " s");
            sample.find('.responseCode').text(d.responseCode);
            sample.find('.bytes').text("" + d.bytes + " B");
            return sample.find('.label').text(d.label).attr("href", d.label);
          };
          xAxis = d3.svg.axis().scale(x);
          yAxis = d3.svg.axis().scale(y).orient("left").ticks(6);
          graph = d3.select(canvas[0]);
          graph.selectAll(".mark").data(data).enter().append("circle").attr("class", function(d) {
            if (d.failed) {
              return "mark failed";
            } else {
              return "mark passed";
            }
          }).attr("cx", function(d) {
            return x(d.timeSinceStart);
          }).attr("cy", function(d) {
            return y(d.elapsedTime);
          }).attr("r", 2.5).on("mouseover", showSample);
          graph.append("g").attr("class", "axis").call(yAxis);
          return graph.append("g").attr("class", "axis").attr("transform", "translate(0, " + height + ")").call(xAxis);
        });
      }

      return ResponseTimeScatterPlot;

    })();
  });

}).call(this);
