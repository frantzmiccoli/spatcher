{expect} = require 'chai'
request = require 'express-mock-request'
Q = require 'q'


spatcher = require 'spatcher'
counterController = require 'spatcher/test/mockControllers/counterController'
app = (require 'express')()

testUrl = (urlToTest) ->
  deferred = Q.defer()
  request(app).get(urlToTest).expect (response) ->
    deferred.resolve(response)
  deferred.promise

spatcherInstance = spatcher(app, 'spatcher/test/mockControllers')


describe 'spatcher', ->
  it 'should correctly dispatch request', (done) ->
    testUrl('/').then (response) ->
      expect(response.statusCode).to.equal 404
    .then ->
      testUrl('/counter')
    .then (response) ->
      expect(response.statusCode).to.equal 200
      expect(counterController.callsHistory.length).to.equal 1
      expect(counterController.callsHistory[0].name).to.equal 'indexAction'
    .then ->
      testUrl('/counter/existing')
    .then (response) ->
      expect(response.statusCode).to.equal 200
      expect(counterController.callsHistory.length).to.equal 2
      expect(counterController.callsHistory[1].name).to.equal 'existingAction'
    .then ->
      testUrl('/counter/_someProtectedMethod')
    .then (response) ->
      expect(response.statusCode).to.not.equal 200
      expect(counterController.callsHistory.length).to.equal 2
    .then ->
      testUrl('/counter/existingSecondOfTheName')
    .then (response) ->
      expect(response.statusCode).to.not.equal 200
      expect(counterController.callsHistory.length).to.equal 2
    .then ->
      done()

  it 'should correctly handle the configuration', (done) ->
    #Updating the spatcherInstance configuration
    spatcherInstance.appendActionToName = false

    testUrl('/counter/existingSecondOfTheName').then (response) ->
      expect(response.statusCode).to.equal 200
      expect(counterController.callsHistory.length).to.equal 3
    .then ->
      #Updating the spatcherInstance configuration
      spatcherInstance.appendControllerToName = false

      testUrl('/counterController/existingSecondOfTheName')
    .then (response) ->
      expect(response.statusCode).to.equal 200
      expect(counterController.callsHistory.length).to.equal 4
    .then ->
      #Updating the spatcherInstance configuration
      spatcherInstance.errorOnActionNameLeadingUnderscore = false

      testUrl('/counterController/_someProtectedMethod')
    .then (response) ->
      expect(response.statusCode).to.equal 200
      expect(counterController.callsHistory.length).to.equal 5
    .then ->
      done()

  it 'should correctly extract parameters', (done) ->
    # Resetting the instance
    spatcherInstance.appendControllerToName = true
    spatcherInstance.appendActionToName = true
    spatcherInstance.errorOnActionNameLeadingUnderscore = true

    url = '/counter/existing/count/123/alphaToken/Hey%20hey%20hey%20%C3%A7/' +
        'alphaToken/42'
    testUrl(url).then (response) ->
      expect(response.statusCode).to.equal 200
      expect(counterController.callsHistory.length).to.equal 6
      expect(counterController.callsHistory[5].name).to.equal 'existingAction'
      req = counterController.callsHistory[5].args[0]
      params = req.params
      expect(params).to.contain.keys('count', 'alphaToken')
      expect(params['alphaToken']).to.include.members(['42', 'Hey hey hey ç'])

      done()