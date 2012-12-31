(function() {

  define(["jquery", "d3", "q"], function($, d3, q) {
    var ReportController;
    return ReportController = (function() {

      function ReportController(elem) {
        this.elem = elem;
      }

      ReportController.prototype.hide = function() {
        return this.elem.addClass("hidden");
      };

      ReportController.prototype.show = function(testCase, build) {
        return this.elem.removeClass("hidden");
      };

      return ReportController;

    })();
  });

}).call(this);
