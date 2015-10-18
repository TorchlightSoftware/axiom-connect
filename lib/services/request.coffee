# create a request helper for test environment
request = require 'request'

module.exports =
  required: ['method', 'path']
  optional: ['body', 'expectedStatus']
  service: ({method, path, body, expectedStatus}, done) ->
    uri = "#{@config.url}/#{path}"
    expectedStatus or= 200

    options = {
      method, uri
    }
    if method is 'get' and body?
      options.query = body
    else if body?
      options.json = body

    @log.info "Requesting: #{method.toUpperCase()} #{uri}"
    request options, (err, res, body) =>
      if err?
        msg = "Expected no request error.  Got:\n"
        newErr = new Error msg + err.message
        newErr.stack = msg + err.stack
        return done(newErr)

      if (typeof body) is 'string'
        try
          body = JSON.parse body
        catch e
          err = new Error 'Expected response body to be json.  Got:\n', body
          return done(err)

      unless res.statusCode is expectedStatus
        @log.warning 'Body for response failure:\n', body
        err = new Error "Expected response status to be #{expectedStatus}.  Got: #{res.statusCode}."
        return done(err)

      done err, {res, body}
