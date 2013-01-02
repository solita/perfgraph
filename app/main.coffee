require.config
  paths:
    "jquery": "components/jquery/jquery"
    "d3": "components/d3/d3.v2"
    "page": "components/page/index"
    "q": "components/q/q"
    "transparency": "components/transparency/lib/transparency"
  shim:
    d3: exports: "d3"
    page: exports: "page"

require ['jquery',
         'd3',
         'page',
         'transparency',
         'controllers/dashboard',
         'controllers/report', ], ($, d3, page, transparency, DashboardController, ReportController) ->

  transparency.register $

  $ ->
    dashboard = new DashboardController $(".dashboard")
    report    = new ReportController $(".report")

    page "/", (ctx) ->
      dashboard.show()
      report.hide()
    page "/reports/:testCase/:build", (ctx) ->
      dashboard.hide()
      report.show ctx.params.testCase, ctx.params.build

    page()
