async = require 'async'
_ = require 'lodash'
logger = require 'torch'

module.exports =
  service: ({server, redirectServer}, done) ->

    # close any servers that exist
    tasks = []
    [server, redirectServer].forEach (s) ->
      tasks.push s.close.bind(s) if s?._handle?

    async.parallel tasks, (err) ->
      done(err)
