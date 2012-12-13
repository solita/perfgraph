require.config
  paths:
    "jquery": "components/jquery/jquery"
    "d3": "components/d3/d3.v2"
    "page": "components/page/index"
  shim:
    d3: exports: "d3"
    page: exports: "page"

require ['jquery', 'd3', 'page', 'controllers/dashboard', 'controllers/report'], ($, d3, page, DashboardController, ReportController) ->
  $ ->
    dashboard = new DashboardController $(".dashboard")
    report    = new ReportController $(".report")

    page "/", (ctx) ->
      dashboard.show()
      report.hide()
    page "/:report/:id", (ctx) ->
      dashboard.hide()
      report.show ctx.params.report, ctx.params.id

    page()
