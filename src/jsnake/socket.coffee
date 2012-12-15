
IS_NODE = exports? and module? and module.exports?

if IS_NODE
	jsnake = require "./jsnake"
else
	jsnake = @jsnake
	

# ## Socket Class (interface)
class Socket
	# - `fnName` [String] is the function name
	# - `arg` [(any)] is the arguments in the remote function `fnName`.
	# - `fn(result)` [Function] is the callback to be called on returning from callee.
	call: (fnName, arg, fn) ->
	# - `fnName` [String] is the function name
	# - `fn(result, cb)` [Function] is the callback to return the result to caller.
	on: (fnName, fn) ->
	

# ## SocketByRemote
class SocketByRemote extends Socket

	PREFIX = "jsnake-socket"

	constructor: (@remote) ->

	on: (name, fn) ->
		obj = {}
		obj["#{PREFIX}-#{name}"] = fn
		@remote.register obj
			

	call: (name, args, fn) ->
		@remote.call "#{PREFIX}-#{name}", args, fn



# ## Exports

do =>
	jsnake.socket = 
		Socket: Socket
		SocketByRemote: SocketByRemote




