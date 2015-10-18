{join} = require 'path'
fs = require 'fs'
_ = require 'lodash'

http = require 'http'
https = require 'https'

read = (file) -> fs.readFileSync file, 'utf8'

module.exports =
  service: ({app}, done) ->
    server = null
    redirectServer = null

    finished = _.once (err) =>
      @log.info "Started server on port #{@config.port}."
      done err, {server, redirectServer}

    if @config.ssl

      # read cert files
      ca = config.app.ssl.ca || []
      options =
        key: read config.app.ssl.key
        cert: read config.app.ssl.cert
        ca: ca.map read

      # create server with ssl
      server = https.createServer(options, app).listen @config.port, finished

      #http server to redirect to https
      if @config.ssl.redirectFrom?
        redirect = (req, res) ->
          redirectTarget = "https://#{req.headers.host}#{req.url}"
          res.writeHead 301, {
            "Location": redirectTarget
          }
          res.end()
        redirectServer = http.createServer(redirect).listen config.app.ssl.redirectFrom

    else
      server = http.createServer(app).listen @config.port, finished
      server.on 'error', (e) =>
        finished new Error "Failed to start server on port: #{@config.port}\n#{e.stack}"
