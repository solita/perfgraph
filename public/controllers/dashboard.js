(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(["jquery", "controllers/error-graph", "controllers/response-time-graph", "controllers/response-time-heat-map", "controllers/response-time-scatterplot"], function($, ErrorGraph, ResponseTimeGraph, ResponseTimeHeatMap, ResponseTimeScatterPlot) {
    var DashboardController;
    return DashboardController = (function() {

      function DashboardController(elem) {
        var columnCount, height, rowCount, t, testCases, width;
        this.elem = elem;
        this.update = __bind(this.update, this);

        columnCount = this.elem.find("tr:first-child td").length;
        rowCount = this.elem.find("tr").length;
        height = $(window).height() * 0.7 / (rowCount - 1);
        width = $(window).width() * 0.7 / (columnCount - 1);
        testCases = ["lh", "rt", "vo"];
        this.elem.find(".graph").width(width).height(height);
        this.responseTimeTrends = (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = testCases.length; _i < _len; _i++) {
            t = testCases[_i];
            _results.push(new ResponseTimeHeatMap(this.elem.find("." + t + ".response-time"), "/response-time-trend/" + t));
          }
          return _results;
        }).call(this);
        this.responseTimeLatests = (function() {
          var _i, _len, _results,
            _this = this;
          _results = [];
          for (_i = 0, _len = testCases.length; _i < _len; _i++) {
            t = testCases[_i];
            _results.push((function(t) {
              var g;
              g = new ResponseTimeScatterPlot(_this.elem.find("." + t + ".response-time.scatter-plot"), "/reports/" + t + "/latest.json", 0.5);
              g.elem.on("click", function(d) {
                return page("/reports/" + t + "/latest");
              });
              return g;
            })(t));
          }
          return _results;
        }).call(this);
        this.update();
        setInterval(this.update, 60 * 1000);
      }

      DashboardController.prototype.update = function() {
        var g, _i, _len, _ref, _results;
        _ref = this.responseTimeLatests;
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
