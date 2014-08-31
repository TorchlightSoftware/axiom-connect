should = require 'should'
logger = require 'torch'
_ = require 'lodash'

makeRouter = require '../lib/helpers/makeRouter'
makeResource = require '../lib/helpers/makeResource'

describe 'makeRouter', ->

  it 'should process standard routes', ->

    routes = [
        path: '/something'
        method: 'get'
        serviceName: 'indexThings'
      ,
        path: '/something/:id'
        method: 'get'
        serviceName: 'showThing'
    ]

    rtr = makeRouter routes
    m = rtr.match '/something'
    should.exist m, 'expected match'
    m.should.containDeep
      params: {}
      splats: []
      route: '/something'
      fn: { get: 'indexThings' }

    m2 = rtr.match '/something/5'
    should.exist m2, 'expected match 2'
    m2.should.containDeep
      params: {id: 5}
      splats: []
      route: '/something/:id'
      fn: { get: 'showThing' }

testData = [
  {
    description: 'have sane defaults'
    routeDef:
      resource: 'photos'
    expected: [
      {
        path: '/photos'
        method: 'get'
        serviceName: 'photos/index'
      }
      {
        path: '/photos/new'
        method: 'get'
        serviceName: 'photos/new'
      }
      {
        path: '/photos'
        method: 'post'
        serviceName: 'photos/create'
      }
      {
        path: '/photos/:id'
        method: 'get'
        serviceName: 'photos/show'
      }
      {
        path: '/photos/:id/edit'
        method: 'get'
        serviceName: 'photos/edit'
      }
      {
        path: '/photos/:id'
        method: 'patch'
        serviceName: 'photos/update'
      }
      {
        path: '/photos/:id'
        method: 'put'
        serviceName: 'photos/update'
      }
      {
        path: '/photos/:id'
        method: 'delete'
        serviceName: 'photos/delete'
      }
    ]
  }
  {
    description: 'let you change the `id` key'
    routeDef:
      resource: 'photos'
      id: 'ident'
    expected: [
      {
        path: '/photos'
        method: 'get'
        serviceName: 'photos/index'
      }
      {
        path: '/photos/new'
        method: 'get'
        serviceName: 'photos/new'
      }
      {
        path: '/photos'
        method: 'post'
        serviceName: 'photos/create'
      }
      {
        path: '/photos/:ident'
        method: 'get'
        serviceName: 'photos/show'
      }
      {
        path: '/photos/:ident/edit'
        method: 'get'
        serviceName: 'photos/edit'
      }
      {
        path: '/photos/:ident'
        method: 'patch'
        serviceName: 'photos/update'
      }
      {
        path: '/photos/:ident'
        method: 'put'
        serviceName: 'photos/update'
      }
      {
        path: '/photos/:ident'
        method: 'delete'
        serviceName: 'photos/delete'
      }
    ]
  }
  {
    description: 'let you specify all path values'
    routeDef:
      resource: 'photographs'
      prefix: 'api'
    expected: [
      {
        path: '/api/photographs'
        method: 'get'
        serviceName: 'photographs/index'
      }
      {
        path: '/api/photographs/new'
        method: 'get'
        serviceName: 'photographs/new'
      }
      {
        path: '/api/photographs'
        method: 'post'
        serviceName: 'photographs/create'
      }
      {
        path: '/api/photographs/:id'
        method: 'get'
        serviceName: 'photographs/show'
      }
      {
        path: '/api/photographs/:id/edit'
        method: 'get'
        serviceName: 'photographs/edit'
      }
      {
        path: '/api/photographs/:id'
        method: 'patch'
        serviceName: 'photographs/update'
      }
      {
        path: '/api/photographs/:id'
        method: 'put'
        serviceName: 'photographs/update'
      }
      {
        path: '/api/photographs/:id'
        method: 'delete'
        serviceName: 'photographs/delete'
      }
    ]
  }
]


describe 'resource generation', () ->
  beforeEach (done) ->
    done()

  for test in testData
    do (test) ->
      {routeDef, description, expected} = test

      it "should #{description}", (done) ->
        routeDefs = makeResource routeDef
        routeDefs.should.eql expected

        done()
