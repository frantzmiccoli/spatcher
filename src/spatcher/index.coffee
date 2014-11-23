Spatcher = require 'spatcher/Spatcher'


module.exports = (args...) ->
  spatcher = new Spatcher()

  if args.length == 0
    # No argument the user just wants a spatcher instance
    return spatcher

  # Some arguments are here, so let's just forward a route call
  app = args[0]
  controllersModule = args[1]
  urlPrefix = args[2]
  spatcher.route(app, controllersModule, urlPrefix)
