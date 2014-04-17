(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(function(require) {
    var $, DashboardController, ErrorGraph, ResponseTimeHeatMap, ResponseTimeScatterPlot, TroughputLine, io, moment, _;
    $ = require("jquery");
    io = require("socket.io");
    moment = require("moment");
    _ = require("lodash");
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
              count: latestBuild.itemCount,
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
        var p, responseTimeLatests, responseTimeTrends, t, throughputGraphs, tietopalveluTestCases, tulosteetTestCases;
        this.elem = elem;
        this.update = __bind(this.update, this);
        this.processBuilds = __bind(this.processBuilds, this);
        tulosteetTestCases = {
          tulosteet: ["lhmu", "lhoulu", "lh", "rt", "vo", "lhro", "omyt", "vuyt"],
          services: ["otpeo", "otpkt", "otpktheijok", "otpktvakjok", "otplt", "otptunn", "otpytunnso", "otpytunnsolkm"]
        };
        tietopalveluTestCases = ["eraajo", "kyselypalvelu", "kyselypalvelu-krkohde", "eraajo-muutos", "kyselypalvelu-muutos"];
        responseTimeTrends = (function() {
          var _i, _len, _ref, _results;
          _ref = _.keys(tulosteetTestCases);
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            p = _ref[_i];
            _results.push((function() {
              var _j, _len1, _ref1, _results1;
              _ref1 = tulosteetTestCases[p];
              _results1 = [];
              for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
                t = _ref1[_j];
                _results1.push(new ResponseTimeHeatMap(this.elem.find("." + p + "." + t + ".response-time"), "/response-time-trend/" + p + "/" + t));
              }
              return _results1;
            }).call(this));
          }
          return _results;
        }).call(this);
        responseTimeLatests = (function() {
          var _i, _len, _ref, _results;
          _ref = _.keys(tulosteetTestCases);
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            p = _ref[_i];
            _results.push((function() {
              var _j, _len1, _ref1, _results1;
              _ref1 = tulosteetTestCases[p];
              _results1 = [];
              for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
                t = _ref1[_j];
                _results1.push((function(_this) {
                  return function(p, t) {
                    var g;
                    g = new ResponseTimeScatterPlot(_this.elem.find("." + p + "." + t + ".response-time-scatter-plot"), "/reports/" + p + "/" + t + "/latest.json", 0.5);
                    g.elem.on("click", function(d) {
                      return page("/reports/" + p + "/" + t + "/latest");
                    });
                    return g;
                  };
                })(this)(p, t));
              }
              return _results1;
            }).call(this));
          }
          return _results;
        }).call(this);
        throughputGraphs = (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = tietopalveluTestCases.length; _i < _len; _i++) {
            t = tietopalveluTestCases[_i];
            _results.push(new TroughputLine(this.elem.find("." + t + ".throughput"), "/" + t + "/throughput.json", updateCallback(this.elem.find("." + t + ".tietopalvelu.status .tbody"))));
          }
          return _results;
        }).call(this);
        this.graphs = _.flatten(responseTimeTrends.concat(responseTimeLatests, throughputGraphs));
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
