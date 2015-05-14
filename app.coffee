fs = require 'fs'
express = require 'express'
app = express()

app.get '/', (req, res)->
	index_html = fs.readFileSync("#{__dirname}/index.html")
	res.send index_html

app.use '/bower_components', express.static "#{__dirname}/bower_components"
app.use '/js', express.static "#{__dirname}/js"

server = app.listen 8081, ->

	host = server.address().address
	port = server.address().port

	console.log "Started, listening at http://#{host}:#{port}"
