logger = require 'torch'

module.exports = (app) ->
  app.use (req, res, next) ->
    if req.url is '/special'

      res.setHeader "Content-Type", "application/json"
      res.statusCode = 200
      res.end '{special: true}'

    else
      next()
