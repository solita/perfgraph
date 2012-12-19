(function() {

  define(["jquery", "controllers/error-graph", "controllers/response-time-graph"], function($, ErrorGraph, ResponseTimeGraph) {
    var ReportController;
    return ReportController = (function() {

      function ReportController(elem) {
        this.elem = elem;
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
