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
