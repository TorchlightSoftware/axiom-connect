law = require 'law'
logger = require 'torch'
{join} = require 'path'

rel = (args...) -> join __dirname, args...

module.exports =
  config:
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

    prefix: 'default'
    middlewareLocation: 'middleware'

  extends:
    'load': ['server.run/load']
    'unload': ['server.run/unload']

  # Services used by the extension
  services: law.load rel('services')
