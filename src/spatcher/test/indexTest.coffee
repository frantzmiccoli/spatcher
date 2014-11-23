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
      #Updating the spatcherInstance configuration
      spatcherInstance.appendActionToName = false

      testUrl('/counter/existingSecondOfTheName')
    .then (response) ->
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

