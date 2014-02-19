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
        tietopalveluTestCases = ["eraajo", "kyselypalvelu", "eraajo-muutos", "kyselypalvelu-muutos"];
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

(function() {
  define(["jquery", "d3", "controllers/response-time-scatterplot"], function($, d3, ResponseTimeScatterPlot) {
    var ReportController;
    return ReportController = (function() {
      var sampleFormatter, updateTopsList;

      sampleFormatter = function(d) {
        d.elapsedTimeStr = d.elapsedTime.toFixed(3);
        return d;
      };

      updateTopsList = function(data) {
        return $(".tops .response-time").render(data.samples.map(sampleFormatter), {
          label: {
            href: function() {
              return this.label;
            }
          }
        });
      };

      function ReportController(elem) {
        this.elem = elem;
        this.scatterPlot = new ResponseTimeScatterPlot(this.elem.find(".graph"), "", 2);
      }

      ReportController.prototype.hide = function() {
        return this.elem.addClass("hidden");
      };

      ReportController.prototype.show = function(project, testCase, build) {
        this.elem.find(".testCaseId").text(testCase);
        this.elem.find(".build").text(build);
        this.elem.removeClass("hidden");
        return this.scatterPlot.update("/reports/" + project + "/" + testCase + "/" + build + ".json", updateTopsList);
      };

      return ReportController;

    })();
  });

}).call(this);

(function() {
  define(["jquery", "d3", "q"], function($, d3, q) {
    var ResponseTimeGraph;
    return ResponseTimeGraph = (function() {
      function ResponseTimeGraph(canvas, url, currentBuild) {
        var data, height, width;
        currentBuild || (currentBuild = []);
        height = canvas.height();
        width = canvas.width();
        data = q.when($.getJSON(url));
        data.then(function(data) {
          var graph, line, x, xAxis, y, yAxis;
          x = d3.scale.linear().domain([0, data.length + 1]).range([0, width]);
          y = d3.scale.linear().domain([0, 60]).range([height, 0]);
          xAxis = d3.svg.axis().scale(x).ticks(0).tickSize(0);
          yAxis = d3.svg.axis().scale(y).orient("left").ticks(3).tickSize(3);
          graph = d3.select(canvas[0]);
          line = d3.svg.line().x(function(d) {
            return x(d[0]);
          }).y(function(d) {
            return y(d[1]);
          });
          graph.selectAll(".current-build").data(currentBuild).enter().append("path").attr("d", function(currentBuild, i) {
            return line([[currentBuild, 0], [currentBuild, -1.5]]);
          }).attr("class", "current-build");
          graph.selectAll(".boxplot.min-max").data(data).enter().append("path").attr("d", function(d, i) {
            return line([[i, d.min], [i, d.max]]);
          }).attr("class", "boxplot min-max");
          graph.selectAll(".boxplot.percentiles").data(data).enter().append("path").attr("d", function(d, i) {
            return line([[i, d.lowerPercentile], [i, d.upperPercentile]]);
          }).attr("class", "boxplot percentiles").on("click", function(d) {
            return page("/reports/" + d.build);
          });
          graph.selectAll(".boxplot.median").data(data).enter().append("path").attr("d", function(d, i) {
            return line([[i - 0.2, d.median], [i + 0.2, d.median]]);
          }).attr("class", "boxplot median");
          graph.append("g").attr("class", "axis").call(yAxis);
          return graph.append("g").attr("class", "axis").attr("transform", "translate(0, " + height + ")").call(xAxis);
        });
      }

      return ResponseTimeGraph;

    })();
  });

}).call(this);

(function() {
  define(["jquery", "d3"], function($, d3) {
    var ResponseTimeHeatMap;
    return ResponseTimeHeatMap = (function() {
      function ResponseTimeHeatMap(elem, url) {
        this.elem = elem;
        this.url = url;
        this.height = this.elem.height();
        this.width = this.elem.width();
      }

      ResponseTimeHeatMap.prototype.update = function() {
        return $.getJSON(this.url, (function(_this) {
          return function(data) {
            var firstBuild, graph, labels, lastBuild, maxTime, showLabel, tiles, x, xAxis, y, yAxis, z, _i, _results;
            lastBuild = d3.max(data.buckets, function(d) {
              return d.build;
            });
            firstBuild = d3.min(data.buckets, function(d) {
              return d.build;
            });
            maxTime = d3.max(data.buckets, function(d) {
              return d.bucket;
            });
            x = d3.scale.ordinal().domain((function() {
              _results = [];
              for (var _i = firstBuild; firstBuild <= lastBuild ? _i <= lastBuild : _i >= lastBuild; firstBuild <= lastBuild ? _i++ : _i--){ _results.push(_i); }
              return _results;
            }).apply(this)).rangeBands([0, _this.width], 0.1);
            y = d3.scale.linear().domain([0, Math.max(maxTime, 10)]).range([_this.height, 0]).nice();
            z = d3.scale.sqrt().domain([
              0, d3.max(data.buckets, function(d) {
                return d.count;
              })
            ]).range(["lightblue", "black"]);
            xAxis = d3.svg.axis().scale(x).tickSize(0);
            yAxis = d3.svg.axis().scale(y).orient("left").ticks(3).tickSize(3);
            graph = d3.select(_this.elem[0]);
            graph.selectAll(".axis").remove();
            graph.append("g").attr("class", "y axis").call(yAxis);
            graph.select(".y.axis").append("text").attr("class", "y label").attr("text-anchor", "end").attr("y", -36).attr("dy", ".75em").attr("transform", "rotate(-90)").text("response time [s]");
            graph.append("g").attr("class", "x axis").attr("transform", "translate(0, " + _this.height + ")").call(xAxis).selectAll("text").attr("class", "build").classed("hidden", function(build) {
              return build !== firstBuild && build !== lastBuild;
            });
            graph.select(".x.axis").append("text").attr("class", "x label").attr("text-anchor", "end").attr("x", _this.width + 7).attr("y", 20).text("build #");
            labels = graph.selectAll(".x.axis .build");
            showLabel = function(d) {
              return labels.classed("hidden", function(build) {
                return build !== firstBuild && build !== lastBuild && build !== d.build;
              });
            };
            tiles = graph.selectAll(".tile").data(data.buckets).attr("x", function(d) {
              return x(d.build);
            }).attr("y", function(d) {
              return y(d.bucket);
            }).attr("width", function(d) {
              return x.rangeBand();
            }).attr("height", function(d) {
              return y(d.bucket) - y(d.bucket + data.bucketSize);
            }).style("fill", function(d) {
              return z(d.count);
            }).on("click", function(d) {
              return page("/reports/" + data.project + "/" + data.testCase + "/" + d.build);
            });
            tiles.enter().append("rect").attr("class", "tile").on("mouseover", showLabel).attr("x", function(d) {
              return x(d.build);
            }).attr("y", function(d) {
              return y(d.bucket);
            }).attr("width", function(d) {
              return x.rangeBand();
            }).attr("height", function(d) {
              return y(d.bucket) - y(d.bucket + data.bucketSize);
            }).style("fill", function(d) {
              return z(d.count);
            }).on("click", function(d) {
              return page("/reports/" + data.project + "/" + data.testCase + "/" + d.build);
            });
            return tiles.exit().remove();
          };
        })(this));
      };

      return ResponseTimeHeatMap;

    })();
  });

}).call(this);

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
        if (url == null) {
          url = this.url;
        }
        this.height = this.elem.height();
        this.width = this.elem.width();
        return $.getJSON(url, (function(_this) {
          return function(data) {
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
          };
        })(this));
      };

      return ResponseTimeScatterPlot;

    })();
  });

}).call(this);

(function() {
  define(["jquery", "d3", "lodash", "transparency"], function($, d3, _) {
    var ThroughputLine;
    return ThroughputLine = (function() {
      function ThroughputLine(elem, url, updateCallback) {
        this.elem = elem;
        this.url = url;
        this.updateCallback = updateCallback;
        this.width = this.elem.width();
        this.height = this.elem.height();
      }

      ThroughputLine.prototype.update = function() {
        return $.getJSON(this.url, (function(_this) {
          return function(data) {
            var flatData, graph, line, lines, x, xAxis, y, yAxis, z;
            flatData = _.flatten(data);
            x = d3.scale.linear().domain(d3.extent(flatData, function(d) {
              return d.build;
            })).range([0, _this.width]).nice();
            y = d3.scale.linear().domain([
              0, d3.max(flatData, function(d) {
                return d.throughput;
              })
            ]).range([_this.height, 0]).nice();
            z = d3.scale.category10().domain(flatData.map(function(d) {
              return d.testCaseId;
            }));
            if (_this.updateCallback) {
              _this.updateCallback(data, z);
            }
            xAxis = d3.svg.axis().scale(x).tickSize(0).tickValues(_.uniq(flatData.map(function(d) {
              return d.build;
            }))).tickFormat(d3.format(",.0f"));
            yAxis = d3.svg.axis().scale(y).orient("left").ticks(5).tickSize(3);
            graph = d3.select(_this.elem[0]);
            line = d3.svg.line().x(function(d) {
              return x(d.build);
            }).y(function(d) {
              return y(d.throughput);
            });
            lines = graph.selectAll(".line").data(data).attr("d", line).style("stroke", function(d) {
              return z(d[0].testCaseId);
            });
            lines.enter().append("path").attr("class", "line").attr("d", line).style("stroke", function(d) {
              return z(d[0].testCaseId);
            });
            lines.exit().remove();
            graph.selectAll(".axis").remove();
            graph.append("g").attr("class", "y axis").call(yAxis).append("text").attr("class", "y label").attr("text-anchor", "end").attr("y", -36).attr("dy", ".75em").attr("transform", "rotate(-90)").text("throughput [1/s]");
            return graph.append("g").attr("class", "x axis").attr("transform", "translate(0, " + _this.height + ")").call(xAxis).append("text").attr("class", "x label").attr("text-anchor", "end").attr("x", _this.width + 7).attr("y", 20).text("build #");
          };
        })(this));
      };

      return ThroughputLine;

    })();
  });

}).call(this);

(function() {
  require.config({
    paths: {
      "jquery": "components/jquery/jquery",
      "d3": "components/d3/d3.v2",
      "socket.io": "socket.io/socket.io",
      "page": "components/page/index",
      "q": "components/q/q",
      "transparency": "components/transparency/lib/transparency",
      "moment": "components/moment/moment",
      "lodash": "components/lodash/lodash"
    },
    shim: {
      d3: {
        exports: "d3"
      },
      "socket.io": {
        exports: "io"
      },
      page: {
        exports: "page"
      },
      moment: {
        exports: "moment"
      }
    }
  });

  require(['jquery', 'page', 'transparency', 'controllers/dashboard', 'controllers/report'], function($, page, transparency, DashboardController, ReportController) {
    transparency.register($);
    return $(function() {
      var dashboard, report;
      dashboard = new DashboardController($(".dashboard"));
      report = new ReportController($(".report"));
      page("/", function(ctx) {
        dashboard.show();
        return report.hide();
      });
      page("/reports/:project/:testCase/:build", function(_arg) {
        var build, project, testCase, _ref;
        _ref = _arg.params, project = _ref.project, testCase = _ref.testCase, build = _ref.build;
        dashboard.hide();
        return report.show(project, testCase, build);
      });
      return page();
    });
  });

}).call(this);
