(function() {

  define(["jquery", "controllers/error-graph", "controllers/response-time-graph", "controllers/response-time-heat-map"], function($, ErrorGraph, ResponseTimeGraph, ResponseTimeHeatMap) {
    var DashboardController;
    return DashboardController = (function() {

      function DashboardController(elem) {
        var columnCount, height, rowCount, width;
        this.elem = elem;
        columnCount = this.elem.find("tr:first-child td").length;
        rowCount = this.elem.find("tr").length;
        height = $(window).height() * 0.7 / (rowCount - 1);
        width = $(window).width() * 0.7 / (columnCount - 1);
        $(".graph").width(width).height(height);
        this.lhResponseTime = new ResponseTimeHeatMap(this.elem.find(".lh.response-time"), "/response-time-raw/lh");
        this.rtResponseTime = new ResponseTimeHeatMap(this.elem.find(".rt.response-time"), "/response-time-raw/rt");
        this.voResponseTime = new ResponseTimeHeatMap(this.elem.find(".vo.response-time"), "/response-time-raw/vo");
        this.lhErrors = new ErrorGraph(this.elem.find(".lh.error-percentage"));
        this.rtErrors = new ErrorGraph(this.elem.find(".rt.error-percentage"));
        this.voErrors = new ErrorGraph(this.elem.find(".vo.error-percentage"));
      }

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
