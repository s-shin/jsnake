# top level namespace

IS_NODE = exports? and module? and module.exports?

# ## jsnake namespace
class jsnake

	# ### Basic Information

	@version = "0.0.1"
	@author = "shin"
	@email = "s2pch.luck@gmail.com"
	@copyright = "(C) 2012 shin"
	@created = "20120830"
	@modified = "20121028"

	# ### namespaces
	@core = {}
	@component = {}
	@player = {}
	@socket = {}
	@util = {}
	@dep = {}

	# ### Setuppers (Entry Points)

	# #### prepare
	# This must be called before accessing `jsnake.input` (e.g. `jsnake.player.*`).
	@prepare = () ->
		@model = null
		@input = new jsnake.core.Input()
		@timer = new jsnake.core.Timer()

	# #### setupOffline
	@setupOffline = (players, foods, onEnd, setupView) ->
		@model = new jsnake.core.OfflineModel players, foods, onEnd
		setupView()

	# #### setupClient
	@setupClient = (socket, vplayers, onEnd, setupView) ->
		@model = new jsnake.core.ClientModel socket, vplayers, onEnd, -> setupView()

	# #### setupServer
	# - `players` [Array(Player)] is the array of `jsnake.player.*` instance
	# - `foods` [Array(Food)] is the array of `jsnake.component.Food` instance
	# - `onEnd` [Function]
	@setupServer = (players, foods, onEnd) ->
		@model = new jsnake.core.ServerModel players, foods, onEnd

	# ### Global Variables
	# These variable is created only once in one session.

	# instance of `jsnake.core.Timer`
	# #### Why `timer`?
	# The time is generally produced in global by the back-end system.
	# In other words, the time deeply depends the system.
	# Using this `timer`, jsnake can use the time with the unified interface.
	@timer = null

	# instance of `jsnake.core.Model`
	@model = null

	# instance of `jsnake.core.Input`
	@input = null
	
	# NOTE: Considering the MVC architecture, `jsnake.model` is the model and
	# `jsnake.input` is the controller. These will be updated in the view.
	
	# ### Constants

	# max player num
	@MAX_PLAYER_NUM = 4

	# cell num
	@CELL_NUM = 
		X: 40, Y: 30


#-----------------------------------

# ## Exports

if IS_NODE
	module.exports = jsnake
else
	@jsnake = jsnake




