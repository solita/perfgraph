(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(function(require) {
    var $, DashboardController, EraajoTroughput, ErrorGraph, ResponseTimeHeatMap, ResponseTimeScatterPlot, io, moment;
    $ = require("jquery");
    io = require("socket.io");
    moment = require("moment");
    ErrorGraph = require("controllers/error-graph");
    ResponseTimeHeatMap = require("controllers/response-time-heat-map");
    ResponseTimeScatterPlot = require("controllers/response-time-scatterplot");
    EraajoTroughput = require("controllers/eraajo-throughput");
    return DashboardController = (function() {

      function DashboardController(elem) {
        var testCases;
        this.elem = elem;
        this.update = __bind(this.update, this);

        this.processBuilds = __bind(this.processBuilds, this);

        testCases = ["lh", "rt", "vo"];
        this.graphs = [new EraajoTroughput(this.elem.find(".era-ajo.throughput"), "/eraajo-throughput.json")];
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
