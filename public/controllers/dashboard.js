(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(["jquery", "controllers/error-graph", "controllers/response-time-graph", "controllers/response-time-heat-map", "controllers/response-time-scatterplot"], function($, ErrorGraph, ResponseTimeGraph, ResponseTimeHeatMap, ResponseTimeScatterPlot) {
    var DashboardController;
    return DashboardController = (function() {

      function DashboardController(elem) {
        var columnCount, height, rowCount, width;
        this.elem = elem;
        this.update = __bind(this.update, this);

        columnCount = this.elem.find("tr:first-child td").length;
        rowCount = this.elem.find("tr").length;
        height = $(window).height() * 0.7 / (rowCount - 1);
        width = $(window).width() * 0.7 / (columnCount - 1);
        this.elem.find(".graph").width(width).height(height);
        this.lhResponseTime = new ResponseTimeHeatMap(this.elem.find(".lh.response-time"), "/response-time-trend/lh");
        this.rtResponseTime = new ResponseTimeHeatMap(this.elem.find(".rt.response-time"), "/response-time-trend/rt");
        this.voResponseTime = new ResponseTimeHeatMap(this.elem.find(".vo.response-time"), "/response-time-trend/vo");
        this.lhScatterPlot = new ResponseTimeScatterPlot(this.elem.find(".lh.response-time.scatter-plot"), "/reports/lh/latest.json", 0.5);
        this.rtScatterPlot = new ResponseTimeScatterPlot(this.elem.find(".rt.response-time.scatter-plot"), "/reports/rt/latest.json", 0.5);
        this.voScatterPlot = new ResponseTimeScatterPlot(this.elem.find(".vo.response-time.scatter-plot"), "/reports/vo/latest.json", 0.5);
        this.lhScatterPlot.elem.on("click", function(d) {
          return page("/reports/lh/latest");
        });
        this.rtScatterPlot.elem.on("click", function(d) {
          return page("/reports/rt/latest");
        });
        this.voScatterPlot.elem.on("click", function(d) {
          return page("/reports/vo/latest");
        });
        this.update();
        setInterval(this.update, 60 * 1000);
      }

      DashboardController.prototype.update = function() {
        var g, _i, _len, _ref, _results;
        _ref = [this.lhScatterPlot, this.rtScatterPlot, this.voScatterPlot];
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          g = _ref[_i];
          _results.push(g.update());
        }
        return _results;
      };

      DashboardController.prototype.hide = function() {
        return $('.dashboard').addClass("hidden");
      };

      DashboardController.prototype.show = function() {
        return $('.dashboard').removeClass("hidden");
      };

      return DashboardController;

    })();
  });

}).call(this);
