(function() {

  define(["jquery", "d3", "controllers/response-time-scatterplot"], function($, d3, ResponseTimeScatterPlot) {
    var ReportController;
    return ReportController = (function() {

      function ReportController(elem) {
        this.elem = elem;
        this.scatterPlot = new ResponseTimeScatterPlot(this.elem.find(".graph"), "", 2);
      }

      ReportController.prototype.hide = function() {
        return this.elem.addClass("hidden");
      };

      ReportController.prototype.show = function(testCase, build) {
        this.elem.find(".testCaseId").text(testCase);
        this.elem.find(".build").text(build);
        this.elem.removeClass("hidden");
        return this.scatterPlot.update("/reports/" + testCase + "/" + build + ".json");
      };

      return ReportController;

    })();
  });

}).call(this);
