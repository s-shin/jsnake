path = require "path"

# get express instance
express = require "express"
app = express()

# Global setting
app.configure () ->
	app.set "port", process.env.PORT || 3000
	app.set "view", "views"
	app.set "view engine", "jade"
	app.use express.favicon()
	app.use express.logger("dev")
	app.use express.bodyParser()
	app.use express.methodOverride()
	app.use app.router
	app.use express.static "public"

# development
app.configure "development", () ->
	app.use express.errorHandler()

# production
app.configure "production", () ->
	app.set "port", 80

# create server
server = require("http").createServer(app).listen app.get("port"), () ->
	console.log "Express server listening on port #{app.get('port')}."

# create socket.io
io = require("socket.io").listen server

# init others
require("./lib/main")(app, io)



