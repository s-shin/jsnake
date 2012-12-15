#
# async.js - fewer callbacks  
# version 0.1.0  
#
# (C) 2012 shin <s2pch.luck@gmail.com>
#
# Licensed under the Apache License 2.0
# http://opensource.org/licenses/Apache-2.0
#

# ## async namespace
async = 

	# ### async.Value
	Value: class
		constructor: (@value=undefined) ->
			@callbacks = []

		get: (fn) ->
			if @value isnt undefined
				fn @value
			else
				@callbacks.push fn

		set: (v) ->
			@value = v
			fn v for fn in @callbacks
			@callbacks = []
			null

	# ### async.getAll
	# This function convert all `async.Value`s to real values.
	#
	# example:
	#
	#     getAll(av1, av2, v3, v4, fn(v1, v2, v3, v4) {
	#       // come here after av1 and av2 is set.
	#     });
	# 
	getAll: (avs..., fn) ->
		vs = []
		next = () ->
			return fn vs... if avs.length is 0
			v = avs.shift()
			if v instanceof async.Value
				v.get (v) ->
					vs.push v
					next()
			else
				vs.push v
				next()
		next()
	
	# ### async.call
	# Call (a)synchronous function with (a)synchronous arguments.
	# If that function return a instance of `async.Value`, it is extracted
	# internally.
	#
	# example:
	#
	#     fn = function(v1, v2, v3, v4, ...) { ... };
	#     av = call(fn, av1, v2, avs3, v4, ...);
	#
	call: (fn, avs...) ->
		rav = new async.Value
		async.getAll avs..., (vs...) ->
			async.getAll (fn vs...), (r) -> rav.set(r)
		rav
	
	# ### async.compose2
	# example:
	# 
	#     f = function(x) { ... };
	#     g = function(x) { ... };
	#     fg = compose(f, g); // f(g(x))
	#     av = fg(x);
	#
	compose2: (f, g) ->
		(args...) ->
			async.call f, (async.call g, args...)
	
	# ### async.compose
	# example:
	#
	#     f = function(x) { ... };
	#     g = function(x) { ... };
	#     fgfg = compose(f, g, f, g); // f(g(f(g(x))))
	#     av = fgfg(x);
	#
	compose: (fns...) ->
		fn = null
		next = (g) ->
			return fn = g if fns.length is 0
			f = fns.pop()
			next async.compose2(f, g)
		next fns.pop()
		fn

	# ### async.connect
	# apply `async.compose` in reverse order
	connect: (fns...) ->
		async.compose fns.reverse()...

		
#-----------------------------------------------

# ## Exports
if exports?
	# node.js
	module.exports = async 
else
	# DOM
	this.async = async




