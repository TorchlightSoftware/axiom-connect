path = require 'path'
fs = require 'fs'

should = require 'should'
axiom = require 'axiom'
request = require 'request'
logger = require 'torch'
_ = require 'lodash'

connect = require '..'
{port} = connect.config

projectDir = path.join(__dirname, '../sample')

describe 'run', ->
  before (done) ->
    axiom.wireUpLoggers [{writer: 'console', level: 'info'}]
    axiom.init {timeout: 200}, {root: projectDir}

    # Given the run command is initiated
    axiom.request "server.run", {}, done

  after (done) ->
    axiom.reset(done)

  it 'should start the server', (done) ->

    # Given a responder exists
    axiom.respond 'connect.routes/hello', (args, fin) ->
      fin null, {greeting: 'hello, world'}

    # When a request is sent
    request {
      url: "http://localhost:#{port}/hello"
      json: true

    }, (err, res, body) ->

      # Then the data from the responder should be received
      should.not.exist err
      should.exist body
      body.should.eql {greeting: 'hello, world'}
      done()


  it 'should accept middleware', (done) ->
    request {
      url: "http://localhost:#{port}/special"
      json: true

    }, (err, res, body) ->

      # Then the data from the responder should be received
      should.not.exist err
      should.exist body
      logger.red body unless res.statusCode is 200
      res.statusCode.should.eql 200

      # why doesn't this get auto-parsed?  am I missing a header?
      body.should.eql '{special: true}'
      done()

  it 'should send no route 404', (done) ->
    request {
      url: "http://localhost:#{port}/nonexistent"
      json: true

    }, (err, res, body) ->

      # Then a 404 should be received
      should.not.exist err
      res.statusCode.should.eql 404
      should.exist body
      body.message.should.eql "No route for: '/nonexistent'"

      done()

  it 'should send no service 404', (done) ->
    request {
      url: "http://localhost:#{port}/noservice"
      json: true

    }, (err, res, body) ->

      # Then a 404 should be received
      should.not.exist err
      res.statusCode.should.eql 404
      should.exist body
      body.message.should.eql "No responders for request: 'connect.routes/noservice'"

      done()

  it 'should respond with static page', (done) ->
    request {
      url: "http://localhost:#{port}/index.html"
      json: true

    }, (err, res, body) ->

      # Then a 200 should be received
      should.not.exist err
      res.statusCode.should.eql 200
      should.exist body
      body.should.include "Welcome!"

      done()
