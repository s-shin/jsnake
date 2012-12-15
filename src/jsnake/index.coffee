# exports for Node.js

IS_NODE = exports? and module? and module.exports?

if IS_NODE
	jsnake = require "./jsnake"
	require "./util"
	require "./component"
	require "./core"
	require "./player"
	require "./socket"
	module.exports = jsnake
else
	console.error "This file exists only for Node.js"
	console.trace()


