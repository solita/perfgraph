(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(function(require) {
    var $, DashboardController, ErrorGraph, ResponseTimeHeatMap, ResponseTimeScatterPlot, TroughputLine, io, moment;
    $ = require("jquery");
    io = require("socket.io");
    moment = require("moment");
    ErrorGraph = require("controllers/error-graph");
    ResponseTimeHeatMap = require("controllers/response-time-heat-map");
    ResponseTimeScatterPlot = require("controllers/response-time-scatterplot");
    TroughputLine = require("controllers/throughput-line");
    return DashboardController = (function() {
      var updateCallback;

      updateCallback = function(elem) {
        return function(data, z) {
          var legendData;
          legendData = data.map(function(d) {
            var latestBuild;
            latestBuild = _.last(d);
            return {
              testCaseId: latestBuild.testCaseId,
              build: latestBuild.build,
              throughput: latestBuild.throughput.toFixed(1),
              errorCount: latestBuild.errorCount
            };
          });
          return elem.render(legendData, {
            stroke: {
              style: function() {
                return "background-color: " + (z(this.testCaseId));
              }
            }
          });
        };
      };

      function DashboardController(elem) {
        var eaTroughput, kpTroughput, responseTimeLatests, responseTimeTrends, t, testCases;
        this.elem = elem;
        this.update = __bind(this.update, this);

        this.processBuilds = __bind(this.processBuilds, this);

        testCases = ["lh", "rt", "vo", "lhro"];
        responseTimeTrends = (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = testCases.length; _i < _len; _i++) {
            t = testCases[_i];
            _results.push(new ResponseTimeHeatMap(this.elem.find("." + t + ".response-time"), "/response-time-trend/" + t));
          }
          return _results;
        }).call(this);
        responseTimeLatests = (function() {
          var _i, _len, _results,
            _this = this;
          _results = [];
          for (_i = 0, _len = testCases.length; _i < _len; _i++) {
            t = testCases[_i];
            _results.push((function(t) {
              var g;
              g = new ResponseTimeScatterPlot(_this.elem.find("." + t + ".response-time-scatter-plot"), "/reports/" + t + "/latest.json", 0.5);
              g.elem.on("click", function(d) {
                return page("/reports/" + t + "/latest");
              });
              return g;
            })(t));
          }
          return _results;
        }).call(this);
        eaTroughput = new TroughputLine(this.elem.find(".eraajo.throughput"), "/eraajo/throughput.json", updateCallback(this.elem.find(".eraajo.tietopalvelu.status .tbody")));
        kpTroughput = new TroughputLine(this.elem.find(".kyselypalvelu.throughput"), "/kyselypalvelu/throughput.json", updateCallback(this.elem.find(".kyselypalvelu.tietopalvelu.status .tbody")));
        this.graphs = responseTimeTrends.concat(responseTimeLatests, [eaTroughput, kpTroughput]);
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
