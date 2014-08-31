module.exports = ->

  staticLocations: [
    @rel 'domain/app/public'
  ]

  routes: [
      path: '/hello'
      method: 'get'
      serviceName: 'hello'
    ,
      path: '/noservice'
      method: 'get'
      serviceName: 'noservice'
  ]
