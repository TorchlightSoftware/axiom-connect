_ = require 'lodash'
{NoRouteError} = require './errors'

module.exports = (err) ->

  options = @config.options

  defaults =
    includeDetails: true
    includeStack: true
    includeMessage: true

  {includeDetails, includeStack, includeMessage} = _.defaults options, defaults

  # statusCode mapping
  if (err instanceof @errorTypes.NoRespondersError)
    statusCode = 404

  else if (err instanceof NoRouteError)
    statusCode = 404

  else
    statusCode = 500

  # Set up the response value
  responseBody = {}

  # Build the 'responseBody' object as indicated by the
  # values of the inclusion flags.
  if includeMessage
    responseBody.message = err.message

  if includeStack
    responseBody.stack = err.stack

  if includeDetails
    _.merge responseBody, err

  return {responseBody, statusCode}
