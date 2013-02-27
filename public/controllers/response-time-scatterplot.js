(function() {

  define(["jquery", "d3", "moment"], function($, d3, moment) {
    var ResponseTimeScatterPlot;
    return ResponseTimeScatterPlot = (function() {

      function ResponseTimeScatterPlot(elem, url, markSize) {
        this.elem = elem;
        this.url = url;
        this.markSize = markSize;
      }

      ResponseTimeScatterPlot.prototype.update = function(url, cb) {
        var _this = this;
        if (url == null) {
          url = this.url;
        }
        this.height = this.elem.height();
        this.width = this.elem.width();
        return $.getJSON(url, function(data) {
          var graph, marks, maxElapsedTime, sample, showSample, x, xAxis, y, yAxis;
          if (cb) {
            cb(data);
          }
          maxElapsedTime = d3.max(data.samples, function(d) {
            return d.elapsedTime;
          });
          _this.elem.find(".testCaseId").text(url);
          x = d3.scale.linear().domain([
            d3.min(data.samples, function(d) {
              return d.timeSinceStart;
            }), d3.max(data.samples, function(d) {
              return d.timeSinceStart;
            })
          ]).range([0, _this.width]).nice();
          y = d3.scale.linear().domain([0, Math.max(maxElapsedTime, 1)]).range([_this.height, 0]).nice();
          sample = $('.report .sample');
          showSample = function(d) {
            var date;
            date = moment.unix(d.timeStamp).format("D.M.YYYY HH:mm:ss");
            sample.find('.timeStamp').text("" + date);
            sample.find('.elapsedTime').text("" + d.elapsedTimeStr + " s");
            sample.find('.responseCode').text(d.responseCode);
            sample.find('.bytes').text("" + d.bytes + " B");
            return sample.find('.label').text(d.label).attr("href", d.label);
          };
          xAxis = d3.svg.axis().scale(x).ticks(6);
          yAxis = d3.svg.axis().scale(y).orient("left").ticks(6);
          graph = d3.select(_this.elem[0]);
          graph.selectAll(".axis").remove();
          graph.append("g").attr("class", "y axis").call(yAxis);
          graph.select(".y.axis").append("text").attr("class", "y label").attr("text-anchor", "end").attr("y", -36).attr("dy", ".75em").attr("transform", "rotate(-90)").text("response time [s]");
          graph.append("g").attr("class", "x axis").attr("transform", "translate(0, " + _this.height + ")").call(xAxis);
          graph.select(".x.axis").append("text").attr("class", "x label").attr("text-anchor", "end").attr("x", _this.width + 13).attr("y", 27).text("request time [s]");
          marks = graph.selectAll(".mark").data(data.samples).attr("class", function(d) {
            if (d.failed) {
              return "mark failed";
            } else {
              return "mark passed";
            }
          }).attr("cx", function(d) {
            return x(d.timeSinceStart);
          }).attr("cy", function(d) {
            return y(d.elapsedTime);
          });
          marks.enter().append("circle").attr("class", function(d) {
            if (d.failed) {
              return "mark failed";
            } else {
              return "mark passed";
            }
          }).attr("cx", function(d) {
            return x(d.timeSinceStart);
          }).attr("cy", function(d) {
            return y(d.elapsedTime);
          }).attr("r", _this.markSize).on("mouseover", showSample);
          return marks.exit().remove();
        });
      };

      return ResponseTimeScatterPlot;

    })();
  });

}).call(this);
