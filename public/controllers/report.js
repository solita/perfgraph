(function() {

  define(["jquery", "controllers/error-graph", "controllers/response-time-graph"], function($, ErrorGraph, ResponseTimeGraph) {
    var ReportController;
    return ReportController = (function() {

      function ReportController(elem) {
        this.elem = elem;
        this.lhResponseTime = new ResponseTimeGraph(this.elem.find(".graph.response-time"), [23]);
        this.lhErrors = new ErrorGraph(this.elem.find(".graph.error-percentage"), [13]);
      }

      ReportController.prototype.hide = function() {
        return this.elem.addClass("hidden");
      };

      ReportController.prototype.show = function() {
        return this.elem.removeClass("hidden");
      };

      return ReportController;

    })();
  });

}).call(this);
