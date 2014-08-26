law = require 'law'
logger = require 'torch'
{join} = require 'path'

rel = (args...) -> join __dirname, args...

module.exports =
  config:
    url: 'http://localhost:4000'
    port: 4000
    ssl: false
    paths:
      public: rel '..', 'public'

    allowAll: true
    options: [
      'compress'
      'responseTime'
      'favicon'
      'staticCache'
      'query'
      'cookieParser'
    ]

    static: ['public']

    middlewareLocation: 'middleware'

  extends:
    'load': ['server.run/load', 'server.test/load']
    'unload': ['server.run/unload', 'server.test/unload']

  # Services used by the extension
  services: law.load rel('services')
