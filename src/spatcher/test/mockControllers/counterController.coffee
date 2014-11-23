class CounterController


  # coffeelint: disable=missing_fat_arrows
  constructor: ->
    # contains objects 'name' of the function called and 'args' for the
    # arguments
    @callsHistory = []
  # coffeelint: enable=missing_fat_arrows


  indexAction: (args...) =>
    @_addToCallHistory('indexAction', args)


  existingAction: (args...) =>
    @_addToCallHistory('existingAction', args)


  existingSecondOfTheName: (args...) =>
    @_addToCallHistory('existingSecondOfTheName', args)


  _someProtectedMethod: (args...) =>
    @_addToCallHistory('_someProtectedMethod', args)


  _addToCallHistory: (methodName, args) =>
    callObject =
      name: methodName
      args: args
    @callsHistory.push(callObject)
    res = args[1]
    res.send('ok', {'Content-Type': 'text/html'}, 200)


module.exports = new CounterController()
