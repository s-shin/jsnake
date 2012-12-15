# Remote v0.4.0  
# (C) 2012 shin <s2pch.luck@gmail.com>  
# Licensed under the Apache License 2.0

IS_NODE = exports? and module? and module.exports?

if IS_NODE
	_ = require "underscore"
else
	_ = @_

# return object traversed `obj` by `props`
findObj = (obj, props) ->
	return obj if props.length is 0
	_(props).reduce (o, p) ->
		return null if not o? or not o[p]?
		o[p]
	, obj

# ## Remote class
class Remote
	
	EVENT = "Remote"

	@ERROR:
		NOT_FOUND: 1
	
	constructor: (@socket) ->
		@id = 0
		@socket.on EVENT, (data, fn) => @onCall data, fn
		@callees = {}
	
	# ### Remote.onCall
	# - `data` [Object]: If `data` is `{names: "foo.bar", args: ...}`,
	#   `foo.bar(args)` is executed.
	# - `fn(err, result)` [Function] is the callback to the remote caller.
	onCall: (data, fn) ->
		names = _(data.name.split ".");
		objName = names.initial()
		fnName = names.last()
		obj = findObj @callees, objName
		unless obj? and obj[fnName]?
			return fn Remote.ERROR.NOT_FOUND
		r = obj[fnName] data.args, (r) -> fn r
		# If the registered and called function didn't return `undefined`,
		# return it.
		fn r if not r
	
	# ### Remote.register
	# set callees
	register: (fns) ->
		_(@callees).extend fns
		
	# ### call_
	# This is a private function and the frontend of `Remote.call` and
	# `Remote.broadcast`.
	call_ = (name, args, fn, socket) ->
		data =
			name: name
			args: args
		socket.emit EVENT, data, (r) -> fn r if fn
	
	# ### Remote.call
	# The remote callee `name` with `args` is called,
	# and then `fn` is called the return value.
	call: (name, args, fn) ->
		call_ name, args, fn, @socket

	# ### Remote.broadcast
	# call `Remote.call` to without the `this.socket`
	broadcast: (name, args, fn) ->
		# NOTE: The callback `fn` may be called some times
		call_ name, args, fn, @socket.broadcast

	# ### Remote.broadcast
	# call `Remote.call` to all sockets
	broadcast2: (name, args, fn) ->
		# NOTE: The callback `fn` may be called some times
		call_ name, args, fn, @socket
		call_ name, args, fn, @socket.broadcast

		
#--------------------------------------------------------

# ## Exports

if IS_NODE
	module.exports = Remote
else
	@Remote = Remote




