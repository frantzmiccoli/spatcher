[![Build Status](https://secure.travis-ci.org/frantzmiccoli/spatcher.png)](http://travis-ci.org/frantzmiccoli/spatcher)

`spatcher` is here to help you to avoid manually writing all routes to dispatch requests in an `express` app.

Getting started
===

Your files should look something like:

```
myAppName/
	app/
		controllers/
			helloController.js
			indexController.js
```

Your `helloController.js` looks like:

```javascript
module.exports = {
	'fooAction': function(req, res) {
		res.send("foo of hello", {'Content-Type': 'text/html'}, 200);
	},
	'indexAction': function(req, res) {
		res.send("index of hello", {'Content-Type': 'text/html'}, 200);
	},
};
```

Your `indexController.js` looks like:

```javascript
module.exports = {
	'indexAction': function(req, res) {
		res.send("index of index", {'Content-Type': 'text/html'}, 200);
	},
};
```

```
npm install --save spatcher
```

Then in your main application file, `app.js` :

```javascript
var app = require('express')();
var spatcher = require('spatcher');

var spatcherInstance = spatcher(app, 'myAppName/app/controllers');

// then you just process as you are used to.
var server = app.listen(3000, function() {
  console.log('Listening on port %d', server.address().port);
});
```

Launch your server:

```
node app.js
```

Then you can just go to:

```
http://localhost:3000/
http://localhost:3000/hello/
http://localhost:3000/hello/foo
```

Advanced usage
===

require('spatcher')()
---

The function returned by the module can be called without any argument. The returned object can be configured and then used to route requests.

```javascript
var spatcherInstance = require('spatcher')();

spatcherInstance.appendControllerToName = false; 
spatcherInstance.appendActionToName  = false;
spatcherInstance.errorOnActionNameLeadingUnderscore = false;

// The path in which controllers will be looked up
var controllersModulePath = 'myApp/myControllers';
// the url prefix to use (default is nothing) in order to look for controllers
var urlPrefix = '/somePrefixInTheUrl';
spatcherInstace.route(expressAppInstance, controllersModulePath, urlPrefix);
```

require('spatcher')(app, controllersModuleRootPath, urlPrefix)
---

If you call the module with some arguments, an object is instantiate and the `route()` method is directly called with the provided arguments.

Multiple controller route and chaining
---

`spatcher` handles multiple routes calling.

```javascript
var app = require('express')();
var spatcherInstance = require('spatcher')();

spatcherInstance.route(app, 'myapp/backoffice/controllers');
spatcherInstance.route(app, 'myapp/frontoffice/controllers');
spatcherInstance.route(app, 'someexternalstuff/controllers', 'extrautil');
```

Configuration
---

Configuration can be done before or after wiring the routes. 

```javascript
var app = require('express')();
var spatcherInstance = require('spatcher')(app, 'app/mycontrollers');

// This option is true by default and happens "Controller" to the name of
// the called module
spatcherInstance.appendControllerToName = false; 

// This option is true by default and happens "Action" to the name
// of the called function
spatcherInstance.appendActionToName  = false;

// This option is true by default, this blocks the call to any function prefixed
// by an underscore (the common naming convention for private function)
spatcherInstance.errorOnActionNameLeadingUnderscore = false;

// ...
```

If you want different configuration for different contexts, you have to call `spatcher` another time.

```javascript
// ...

var secondSpatcherInstance = require('spatcher')(app, 'somemodule/somecontrollersrootpath');

// ...
```

Origin
===

The code base is mostly an extension and a rewrite of some express boilerplate code (I can't find it anymore).

License
===

MIT
