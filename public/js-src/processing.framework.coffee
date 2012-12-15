#
# processing.framework.js  
# version 0.1.0  
# (C) 2012 shin <s2pch.luck@gmail.com>
#
# licensed under the MIT license
# 

#-----------------------------------------------------

# ## PF (Processing Framework) Namespace
# This is a namespace, not a class.
#
# NOTE: In a class of CoffeeScript, `foo` in `foo = bar` is a private function, 
# `@foo` in `@foo: bar` or `@foo = bar` is a public class function, and `foo` in
# `foo: bar` is a public function contained in the prototype.
class PF

	# ### PF.setup (front-end)
	# This function setup `<canvas>` element with `start` [PF.Scene] scene and
	# return `PF.Processing` instance.
	@setup: (canvas, start) ->
		# `new PF.ProcessingEx` return a `PF.Processing` instance.
		new PF.ProcessingEx canvas, start,
			draw: "__draw"
			keyPressed: "__keyPressed"
			keyReleased: "__keyReleased"
		
	# ### Processing Instances Management
	# Users can get the original `Processing` instance
	# via `PF.getInstance` with `PF.Processing.id`
	instances = {}
	setInstance = (id, instance) -> instances[id] = instance
	@getInstance: (id) -> @instances[i]

	# ### Events in Processing
	EVENTS = ["setup", "draw",
		"mouseClicked", "mouseDragged", "mouseMoved",
		"mouseOut", "mouseOver", "mousePressed", "mouseReleased",
		"keyPressed", "keyReleased"]

	# ### PF.Processing Class
	# This class is wrapper class of the original `Processing` class.
	# `PF.Processing.id` is also set to the `data-pfid` attribute
	# of the target `<canvas>`.
	@Processing: class
		id = 0
		constructor: (canvas, sketch) ->
			@id = id++
			if canvas.dataset # html5 dataset
				canvas.dataset.pfid = @id # almost modern browsers
			else
				canvas.setAttribute "data-pfid" # maybe IE
			# create instance
			processing = new Processing canvas, (p) ->
				for k, v of EVENTS
					do (k, v) ->
						p[v] = (-> sketch[v](p)) if sketch[v]
			# stock instance
			setInstance @id, processing
			

	# ### PF.ProcessingEx Class
	# This class gives `PF.Processing` a simple scene management system.
	@ProcessingEx: class

		# `{ setup: "setup", draw: "draw", ... }`
		DEFAULT_EVENT_MAPPING = do ->
			ret = {}
			ret[v] = v for v, i in EVENTS
			ret

		# #### Constructor
		# - `canvas` [Element] is the target `<canvas>` element
		# - `start` [PF.Scene] is the first `PF.Scene` instance
		# - `eventMapping` [Object]
		constructor: (canvas, start, eventMapping=null) ->
				if eventMapping
					for k, v of DEFAULT_EVENT_MAPPING
						eventMapping[k] ?= v
				else
					eventMapping = DEFAULT_EVENT_MAPPING

				sketch = {}
				current = start

				for v in EVENTS
					do (v) ->
						sketch[v] = (p) ->
							eventFn = current[eventMapping[v]]
							return if not eventFn
							# Execute events.
							# Event functions return next scene.
							next = eventFn.call(current, p)
							return if not next
							# Change current scene to next scene and execute setup event.
							# Nested changing (if setup events return next scene) is
							# also supported.
							while true
								setupFn = next[eventMapping["setup"]]
								break if not setupFn
								next2 = setupFn.call(next, p)
								break if not next2
								next = next2
							current = next

				return new PF.Processing canvas, sketch

	#-----------------------------------------------------
	# For the framework

	# ### PF.Key Class
	# This class supports pressing multiple key.
	@Key: class
		constructor: () -> @key = {}
		press: (k) -> @key[@getCode k] = true
		release: (k) -> @key[@getCode k] = false
		isPressed: (k) -> @key[@getCode k]
		getCode: (k) ->
			# `keyCode` in the `Processing` is the upper-case character code
			# (detected by some experiments).
			if typeof k is "string" then k.toUpperCase().charCodeAt() else k


	# ### PF.Scene Class (base scene class)
	@Scene: class
		constructor: () -> @key = new PF.Key
	
		# private functions

		__draw: (p) -> @update(p) || @draw(p)
		__keyPressed: (p) -> @key.press p.keyCode; @keyPressed p
		__keyReleased: (p) -> @key.release p.keyCode; @keyReleased p

		# protected functions

		update: (p) -> null
		draw: (p) -> null
		keyPressed: (p) -> null
		keyReleased: (p) -> null
		

	#-----------------------------------------------------

	# UI Classes (beta)

	# ### PF.UIBase Class
	@UIBase: class
		draw: (p) -> # ...
		update: (p) -> # ...
		
	# ### PF.UIManager Class
	@UIManager: class
		draw: (p) ->
		update: (p) ->
		
	# ### PF.Button Class
	@Button: class extends PF.UIBase
		constructor: (@x, @y, @w, @h, @radius, @bg1, @bg2) ->
			@active = false
	
		draw: (p) ->
			p.pushStyle()
			p.noStroke()
			p.fill (if @active then @bg2 else @bg1)...
			p.draw @x, @y, @w, @h, @radius
			p.popStyle()
	
			
	# ### PF.TextButton Class
	@TextButton: class extends PF.Button
		constructor: (p, @x, @y, @radius, @bg1, @bg2, @font, @size, @text) ->
			padding = @size * 0.4
			@h = @size + padding
			@w = p.fontWidth(@text) + padding
			super @x, @y, @w, @h, @radius, @bg1, @b2

		draw: (p) ->
			super p
			p.pushStyle()
			p.textFont @font, @size
			p.textAlign p.CENTER, p.CENTER
			p.text @text, @x, @y, @w, @h
			p.popStyle()


# ## Exports

IS_NODE = exports? and module? and module.exports?

unless IS_NODE # DOM
	@PF = PF




