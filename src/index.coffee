fs = require 'fs'
path = require 'path'

_ = require 'lodash'
express = require 'express'
bodyParser = require 'body-parser'
Promise = require 'when'

Configurations = require './configurations'

app = express()

app.use bodyParser.urlencoded
  extended: true

app.use bodyParser.json()

app.use express.static path.resolve __dirname, '../public'

app.get '/configurations.:format?', (req, res, next) ->
  Configurations.get()
  .done (data) ->
    res.send
      configurations: data?.configurations ? []
  , next

app.post '/configuration/new.:format?', (req, res, next) ->
  configuration = req.body?.configuration
  if configuration.id == 'new'
    delete configuration.id
  Configurations.set configuration
  .done (configuration) ->
    if req.params.format == 'json'
      res.send configuration ? {}
    else
      res.redirect '/'
  , next

app.post '/configuration/:id.:format?', (req, res, next) ->
  console.log 'set by id', req.body?.configuration
  configuration = req.body?.configuration
  if configuration.id == 'new'
    delete configuration.id
  Configurations.set configuration
  .done (configuration) ->
    if req.params.format == 'json'
      res.send configuration ? {}
    else
      res.redirect '/'
  , next

app.post '/configuration/:id/delete.:format?', (req, res, next) ->
  Configurations.delete(req.params.id)
  .done (data) ->
    res.send data?.configurations ? []
  , next

app.get '/', (req, res, next) ->
  fs.createReadStream path.resolve __dirname, '../public/views/index.html'
  .pipe res

app.use (err, req, res, next) ->
  jsonPattern = /^[^?]+\.json$|\?/
  isJson = jsonPattern.test req.originalUrl

  res.status 500

  if isJson
    res.send
      status: 'error'
      error:
        type: err.type
        message: err.message
        stack: err.stack
  else
    res.send 'An error occurred:\n' + String(err)

defaultPort = if process.env.NODE_ENV == 'production'
  80
else
  8000

port = process.env.NODE_PORT ? defaultPort
app.listen port
console.log 'started', port
