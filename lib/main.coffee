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

  extends:
    'run/load': ['server.run/load']
    'run/unload': ['server.run/unload']

  # Services used by the extension
  services: law.load rel('services')
