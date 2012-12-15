IS_NODE = exports? and module? and module.exports?

if IS_NODE
	jsnake = require "./jsnake"
else
	jsnake = @jsnake


# NOTE:
# These method is used not only normally but in implementing the multiple inheritance or
# implemnetation to the class.
# (see the first Q&A in the "Classes" section in
# https://github.com/jashkenas/coffee-script/wiki/FAQ)

# It is almost equivalent to `_.exnted`, maybe.
extend = (target, objs...) ->
	for obj in objs
		for own k, v of obj
			target[k] = v
			
# `target.prototype` is `extend`ed by `objs`.
include = (target, objs...) ->
	extend target.prototype, objs...

# `target.prototype` is `extend`ed by `prototype` of each `interfaces`.
#
# example:
#
#     class Foo extends BaseFoo
#       implement @, InterfaceBar
#       ...
# 
implement = (target, interfaces...) ->
	include target, i.prototype for i in interfaces

# This check whether instance `a` has implemented interface(or class) `A`, by duck test.
# If the `a` inherits `A` by CoffeeScript's `extends`, then you should use `instanceof`.
# Otherwise, if the `a` is mixed in by `extend`ed, `include`d or `implement`ed, 
# then we can use `has_implemented`.
#
# example:
#
#     class Foo extends BaseFoo
#       implement @, InterfaceBar
#       ...
#
#     foo = new Foo
#     foo instanceof BaseFoo # true
#     foo instanceof InterfaceBar # false
#     has_implemented foo, BaseFoo # true
#     has_implemented foo, InterfaceBar # true
# 
has_implemented = (a, A) ->
	for own k, v of A.prototype
		if typeof a[k] isnt typeof v
			return false
	return true
	
# It will make you happy to write `to_be_implemented` in pure virtual function.
to_be_implemented = () ->
	console.error "ERROR: A pure virtual function is not implemented."
	console.trace()


# ### Serializer Class
# TODO: think
class Serializer

	DEFAULT_OBJECT_PATH = "Serializer"

	@Interface: class
		OBJECT_PATH: DEFAULT_OBJECT_PATH
		serialize: () -> to_be_implemented()
		deserialize: () -> to_be_implemented()

	###
	classes: []
	classesHash: {}
		
	appendClass: (cs...) ->
		for c in cs
			@classes.push c
			if c.OBJECT_PATH is DEFAULT_OBJECT_PATH
				console.error "invalid name"
				console.trace()
			else
				@classesHash[c.OBJECT_PATH] = c

	removeClass: (cs...) ->
		for c in cs
			@classes = _(@classes).without c
			delete @classesHash[c.OBJECT_PATH]

	search = (path) ->
		ps = path.split "."
		t = root
		t = t[p] for p in ps
		t

	serialize: (x) ->
		if _.isArray x
			_(x).map (y) => @serialize y
		else if x instanceof Serialize.Interface
			t = x.serialize()
			t.OBJECT_PATH = x.OBJECT_PATH
			@serialize t
		else if _.isObject x
			for own k, v of x
				t = @serialize v
				x[k] = t if t
			x
		else
			x

	deserialize: (x) ->
	###


jsnake.util = 
	extend: extend
	include: include
	implement: implement
	has_implemented: has_implemented
	to_be_implemented: to_be_implemented
	Serializer: Serializer

