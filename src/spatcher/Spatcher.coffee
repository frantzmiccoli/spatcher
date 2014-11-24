class Spatcher

  # coffeelint: disable=missing_fat_arrows
  constructor: ->
    @appendControllerToName = true
    @appendActionToName = true
    @errorOnActionNameLeadingUnderscore = true
  # coffeelint: enable=missing_fat_arrows


  route: (app, controllersModule, urlPrefix = "") =>
    urlPrefix = @_cleanUrlPrefix(urlPrefix)

    #   - _/_ -> controllers/index/index action
    indexUrlPattern = urlPrefix
    app.all indexUrlPattern, (req, res, next) =>
      @_dispatch(controllersModule, 'index', 'index', req, res, next)

    #   - _/**:controller**_  -> controllers/***:controller***/index action
    controllerUrlPattern = urlPrefix + ':controller'
    app.all controllerUrlPattern, (req, res, next) =>
      @_dispatch(controllersModule, req.params.controller, 'index',
        req, res, next)

    #   - _/**:controller**/**:action**_ ->
    # controllers/***:controller***/***:action*** action
    controllerActionUrlPattern = urlPrefix + ':controller/:action'
    app.all controllerActionUrlPattern, (req, res, next) =>
      @_dispatch(controllersModule, req.params.controller, req.params.action,
        req, res, next)

    #   - _/**:controller**/**:action**/**:id**_ ->
    # controllers/***:controller***/***:action*** action with ***:id*** param
    # passed
    controllerActionIdUrlPattern = urlPrefix + ':controller/:action/:id'
    app.all controllerActionIdUrlPattern, (req, res, next) =>
      @_dispatch(controllersModule, req.params.controller, req.params.action,
        req, res, next)

    #   - _/**:controller**/**:action**/**:id**_ ->
    # controllers/***:controller***/***:action*** action with extra params
    # passed as /myctrl/myaction/myparam1/myvalue1/myparam2/myvalue2
    controllerActionStarUrlPattern = urlPrefix + ':controller/:action/*'
    app.all controllerActionStarUrlPattern, (req, res, next) =>
      @_dispatch(controllersModule, req.params.controller, req.params.action,
        req, res, next)

    this


  _extractParameters: (req) ->
    url = req.url
    # The first three elements are an empty string, the controller,
    # the action...
    extraParameters = url.split('?')[0].split('/')[3...]
    if (extraParameters.length % 2) != 0
      return

    # we expand to the req object
    while extraParameters.length != 0
      key = extraParameters.shift()
      parameter = extraParameters.shift()
      if key in ['controller', 'action']
        continue
      if key in Object.keys(req.params)
        # if it's not an array let's make an array of it
        unless req.params[key].push
          req.params[key] = [req.params[key]]
        req.params[key].push(parameter)
      else
        req.params[key] = parameter


  _dispatch: (controllersModule, controllerName, actionName, req, res, next) ->
    controllerName = @_preprocessControllerName(controllerName)
    try
      targetModule = controllersModule + "/" + controllerName
      controller = require(targetModule)
    catch e
      # No error here it might be in another module
      if e.code == 'MODULE_NOT_FOUND'
        console.warn('No controller found: ',
            controllerName, ' looked in ' + targetModule)
        next()
        return
      # This is not a module that has failed loading, that's a true error.
      throw e

    actionName = @_preprocessActionName(actionName)
    if typeof controller[actionName] is 'function'
      actionAction = controller[actionName].bind controller
      @_extractParameters(req)
      actionAction(req, res, next)
    else
      console.warn 'No match for action: ', actionName
      next()


  _cleanUrlPrefix: (urlPrefix) =>
    if urlPrefix.length == 0
      urlPrefix = '/'

    if urlPrefix[0] != '/'
      urlPrefix = '/' + urlPrefix

    if urlPrefix[urlPrefix.length - 1] != '/'
      urlPrefix += '/'

    urlPrefix


  _preprocessControllerName: (controllerName) =>
    controllerName = 'index' if not controllerName?
    if @appendControllerToName
      controllerName += 'Controller'
    controllerName


  _preprocessActionName: (actionName) =>
    actionName = 'index' if not actionName?
    if @errorOnActionNameLeadingUnderscore && (actionName[0] == '_')
      throw new Error('Action call blocked to avoid any private method call,' +
        ' no leading underscore allowed: ' + actionName)

    if @appendActionToName
      actionName += 'Action'
    actionName


module.exports = Spatcher