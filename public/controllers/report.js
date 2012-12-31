(function() {

  define(["jquery", "d3", "controllers/response-time-scatterplot"], function($, d3, ResponseTimeScatterPlot) {
    var ReportController;
    return ReportController = (function() {

      function ReportController(elem) {
        var height, width;
        this.elem = elem;
        height = $(window).height() * 0.5;
        width = $(window).width() * 0.9;
        this.graph = this.elem.find(".graph").width(width).height(height);
      }

      ReportController.prototype.hide = function() {
        return this.elem.addClass("hidden");
      };

      ReportController.prototype.show = function(testCase, build) {
        var scatterPlot;
        this.elem.removeClass("hidden");
        this.graph.empty();
        return scatterPlot = new ResponseTimeScatterPlot(this.graph, "/reports/" + testCase + "/" + build + ".json");
      };

      return ReportController;

    })();
  });

}).call(this);
