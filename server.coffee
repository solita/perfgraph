express = require("express")
http = require("http")
path = require("path")
app = express()

app.configure ->
  app.set "port", process.env.PORT or 3000
  app.use express.favicon()
  app.use express.logger("dev")
  app.use express.bodyParser() # Parsii post-requestista bodyn
  app.use express.methodOverride() # http://stackoverflow.com/questions/8378338/what-does-connect-js-methodoverride-do
  app.use app.router 
  app.use express.static(path.join(__dirname, "public"))

app.configure "development", ->
  app.use express.errorHandler()

app.get "/hello", (req, res) ->
  res.end "Hello world!"

http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")
