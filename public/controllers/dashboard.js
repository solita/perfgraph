(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(function(require) {
    var $, DashboardController, ErrorGraph, ResponseTimeHeatMap, ResponseTimeScatterPlot, io, moment;
    $ = require("jquery");
    io = require("socket.io");
    moment = require("moment");
    ErrorGraph = require("controllers/error-graph");
    ResponseTimeHeatMap = require("controllers/response-time-heat-map");
    ResponseTimeScatterPlot = require("controllers/response-time-scatterplot");
    return DashboardController = (function() {

      function DashboardController(elem) {
        var columnCount, gs, height, proto, rowCount, t, testCases, width, _fn, _i, _len,
          _this = this;
        this.elem = elem;
        this.update = __bind(this.update, this);

        this.processBuilds = __bind(this.processBuilds, this);

        testCases = ["lh", "rt", "vo"];
        columnCount = this.elem.find("tr:first-child td").length;
        rowCount = testCases.length;
        height = $(window).height() * 0.83 / rowCount;
        width = $(window).width() * 0.83 / columnCount;
        this.elem.find(".graph").width(width).height(height);
        proto = this.elem.find("tr.proto");
        gs = [];
        _fn = function(t) {
          var g, n;
          n = proto.clone();
          proto.parent().append(n);
          g = new ResponseTimeHeatMap(n.find(".response-time"), "/response-time-trend/" + t);
          gs.push(g);
          g = new ResponseTimeScatterPlot(n.find(".response-time.scatter-plot"), "/reports/" + t + "/latest.json", 0.5);
          g.elem.on("click", function(d) {
            return page("/reports/" + t + "/latest");
          });
          return gs.push(g);
        };
        for (_i = 0, _len = testCases.length; _i < _len; _i++) {
          t = testCases[_i];
          _fn(t);
        }
        this.graphs = gs;
        proto.remove();
        this.updateButton = $(".update");
        this.updateProgressIcon = $(".progress");
        this.updateButton.on("click", this.processBuilds);
        this.socket = io.connect();
        this.socket.on("change", this.update);
        this.socket.on("reload", function() {
          return location.reload(true);
        });
        this.update();
      }

      DashboardController.prototype.processBuilds = function() {
        this.updateButton.prop("disabled", true);
        this.updateProgressIcon.removeClass("hidden");
        return $.get("/process-builds");
      };

      DashboardController.prototype.update = function() {
        var g, _i, _len, _ref;
        _ref = this.graphs;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          g = _ref[_i];
          g.update();
        }
        this.updateButton.prop("disabled", false);
        return this.updateProgressIcon.addClass("hidden");
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
