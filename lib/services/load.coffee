connect = require 'connect'
_ = require 'lodash'
logger = require 'torch'

getErrorBody = require '../helpers/getErrorBody'
makeRouter = require '../helpers/makeRouter'
makeResource = require '../helpers/makeResource'
{NoRouteError} = require '../helpers/errors'

module.exports =
  service: (args, done) ->

    app = connect()
    app.use (req, res, next) ->
      res.setHeader "Access-Control-Allow-Origin", "*"
      next()
    app.use connect.compress()
    app.use connect.responseTime()
    app.use connect.favicon()
    app.use connect.query()
    app.use connect.cookieParser()
    app.use connect.static @config.paths.public

    app.use connect.urlencoded()
    app.use connect.json()

    # run any additional middleware that the consumer would like
    try
      middleware = @retrieve(@config.middlewareLocation)

    middleware?(app)

    # set up routes
    routes = _.flatten _.map @config.routes, makeResource
    router = makeRouter routes

    match = (req) ->
      method = req.method.toLowerCase()
      pathname = req._parsedUrl.pathname

      found = router.match pathname

      return {
        serviceName: found?.fn[method] or 'notFound'
        params: found?.params
      }

    # respond to requests
    app.use (req, res, next) =>
      send = ({statusCode, responseBody}) ->
        contentType = 'application/json'
        res.writeHead statusCode, contentType
        res.end (JSON.stringify responseBody)

      {body, query, cookies} = req
      {serviceName, params} = match(req)
      if serviceName is 'notFound'
        return send getErrorBody.call @, new NoRouteError {path: req.url}

      args = _.merge {}, body, cookies, query, params

      # connect to message bus
      location = "#{@config.prefix}/#{serviceName}"
      @request location, args, (err, result) =>

        if err?
          response = getErrorBody.call @, err

        else
          responseBody = _.clone result
          delete responseBody.statusCode

          statusCode = result.statusCode or 200
          response = {responseBody, statusCode}

        send response

    @request 'startServer', {app}, (err, {server, redirectServer}) ->
      done err, {app, server, redirectServer}
