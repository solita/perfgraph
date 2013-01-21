require.config
  paths:
    "jquery": "components/jquery/jquery"
    "d3": "components/d3/d3.v2"
    "socket.io": "socket.io/socket.io"
    "page": "components/page/index"
    "q": "components/q/q"
    "transparency": "components/transparency/lib/transparency"
    "moment": "components/moment/moment"
  shim:
    d3: exports: "d3"
    "socket.io": exports: "io"
    page: exports: "page"
    moment: exports: "moment"

require ['jquery',
         'page',
         'transparency',
         'controllers/dashboard',
         'controllers/report'], ($, page, transparency, DashboardController, ReportController) ->

  transparency.register $

  setup = ->
    dashboard = new DashboardController $(".dashboard")
    report    = new ReportController $(".report")

    page "/", (ctx) ->
      dashboard.show()
      report.hide()
    page "/reports/:testCase/:build", (ctx) ->
      dashboard.hide()
      report.show ctx.params.testCase, ctx.params.build

    page()

  setTimeout setup, 1000
