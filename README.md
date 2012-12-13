# Template for client-side web apps

## Out of the box setup

* Grunt tasks for
  * Jade
  * Stylus
  * CoffeeScript
  * LiveReload
* jQuery
* Require.js
* Normalize.css

## Setting up the development environment

```
npm install -g grunt bower coffee-script
npm install
grunt --config grunt.coffee
open http://localhost:6001
```

## Installing components

```
cd public
bower install jquery
bower ls --map
```

Use the output to update `require.config` in `main.coffee` accordingly.

Happy Hacking! :]
