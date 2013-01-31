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

      ReportController.prototype.show = function(testCase, build) {
        this.elem.find(".testCaseId").text(testCase);
        this.elem.find(".build").text(build);
        this.elem.removeClass("hidden");
        return this.scatterPlot.update("/reports/" + testCase + "/" + build + ".json", updateTopsList);
      };

      return ReportController;

    })();
  });

}).call(this);
