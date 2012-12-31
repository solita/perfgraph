(function() {

  define(["jquery", "d3"], function($, d3) {
    var ReportController;
    return ReportController = (function() {

      function ReportController(elem) {
        var height, width;
        this.elem = elem;
        height = $(window).height() * 0.5;
        width = $(window).width() * 0.9;
        this.elem.find(".graph").width(width).height(height);
      }

      ReportController.prototype.hide = function() {
        return this.elem.addClass("hidden");
      };

      ReportController.prototype.show = function(testCase, build) {
        this.elem.removeClass("hidden");
        return $.getJSON("/reports/" + testCase + "/" + build + ".json", function(data) {});
      };

      return ReportController;

    })();
  });

}).call(this);
