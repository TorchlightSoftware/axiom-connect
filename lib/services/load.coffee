connect = require 'connect'
_ = require 'lodash'

getErrorBody = require '../helpers/getErrorBody'
makeRouter = require '../helpers/makeRouter'
makeResource = require '../helpers/makeResource'
{NoRouteError} = require '../helpers/errors'

module.exports =
  service: (args, done) ->

    app = connect()

    if @config.allowAllOrigins
      app.use (req, res, next) ->
        res.setHeader "Access-Control-Allow-Origin", "*"
        next()

    for opt in @config.options
      app.use connect[opt]()

    for path in @config.staticLocations
      app.use connect.static(path)

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
      send = ({responseBody, statusCode}) ->
        contentType = 'application/json'
        res.writeHead statusCode, contentType
        res.end (JSON.stringify responseBody)

      {body, query, cookies} = req
      {serviceName, params} = match(req)
      if serviceName is 'notFound'
        return send getErrorBody.call @, new NoRouteError {path: req.url}

      args = _.merge {}, body, cookies, query, params

      # connect to message bus
      location = "routes/#{serviceName}"
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
