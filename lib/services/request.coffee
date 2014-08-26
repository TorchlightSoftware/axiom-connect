# create a request helper for test environment
request = require 'request'

module.exports =
  required: ['method', 'path']
  service: ({method, path, body}, done) ->
    uri = "#{@config.url}/#{path}"

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

      done err, {res, body}
