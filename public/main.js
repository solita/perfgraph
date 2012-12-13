(function() {

  require.config({
    paths: {
      "jquery": "components/jquery/jquery",
      "d3": "components/d3/d3.v2",
      "page": "components/page/index"
    },
    shim: {
      d3: {
        exports: "d3"
      },
      page: {
        exports: "page"
      }
    }
  });

  require(['jquery', 'd3', 'page', 'controllers/dashboard', 'controllers/report'], function($, d3, page, DashboardController, ReportController) {
    return $(function() {
      var dashboard, report;
      dashboard = new DashboardController($(".dashboard"));
      report = new ReportController($(".report"));
      page("/", function(ctx) {
        dashboard.show();
        return report.hide();
      });
      page("/:report/:id", function(ctx) {
        dashboard.hide();
        return report.show(ctx.params.report, ctx.params.id);
      });
      return page();
    });
  });

}).call(this);
