IS_NODE = exports? and module? and module.exports?

# ## Dependencies

if IS_NODE
	_ = require "underscore"
	jsnake = require "./jsnake"
	require "./util"
	require "./component"
else
	_ = @_
	jsnake = @jsnake


{has_implemented, to_be_implemented} = jsnake.util
{Field, Snake, Food} = jsnake.component

#-----------------------------------

# ## Input Class
class Input

	constructor: () ->
		@inputs = []

	# NOTE: observer pattern

	@Interface: class
		constructor: () -> jsnake.input.add @
		onInput: (raw...) -> to_be_implemented()

	add: (inputs...) -> @inputs = @inputs.concat inputs
	remove: (inputs...) -> @inputs = _(@inputs).without inputs...
	update: (raw...) -> input.onInput(raw...) for input in @inputs


# ## Timer Class
class Timer
	# start with 0
	constructor: () -> @ms = 0
	update: (ms) -> @ms += ms
	now: () -> @ms
	# NOTE: Time span can be smartly got by using closure
	watch: () -> ms = @ms; () => @ms - ms


# ## Model Class (interface)
class Model
	update: () -> to_be_implemented()
	getPlayers: () -> to_be_implemented()
	getFoods: () -> to_be_implemented()


# ## OfflineModel
class OfflineModel extends Model

	constructor: (@players, @foods, @onEnd) ->
		@field = new Field
		@span = jsnake.timer.watch()

	updateField: () ->
		[snakes, @foods] = @field.update (p.snake for p in @players), @foods
		p.snake = snakes[i] for p, i in @players
		null

	update: () ->
		p.update() for p in @players
		if @span() > 100
			@updateField()
			@span = jsnake.timer.watch()
		null

	getPlayers: () -> @players
	getFoods: () -> @foods


# ## ClientModel Class
class ClientModel extends Model

	# `vplayers` [Array(LocalPlayer)] is virtual players.
	constructor: (@socket, @vplayers, @onEnd, fn) ->
		{Food} = jsnake.component
		{Player} = jsnake.player
		@players = null
		@foods = null
		set = (players, foods) =>
			@players = ((new Player).deserialize p for p in players)
			@foods = ((new Food).deserialize f for f in foods)
		@socket.on "update", ([players, foods]) ->
			set players, foods
		@socket.on "start", ([players, foods]) ->
			set players, foods
			fn()
		@span = jsnake.timer.watch()

	update: () ->
		# send only input
		if @span() > 20
			for player in @vplayers
				@socket.call "updateInput", [player.id, player.dir]
			@span = jsnake.timer.watch()

	getPlayers: () -> @players
	getFoods: () -> @foods


# ## ServerModel Class
class ServerModel extends OfflineModel

	get = (players, foods) ->
		[p.serialize() for p in players, f.serialize() for f in foods]

	constructor: (players, foods, onEnd) ->
		super players, foods, onEnd
		for player in players
			player.socket.on "updateInput", ([id, dir]) =>
				# NOTE: overhead is too large?
				p = _(@players).find (p) -> p.id is id
				p.input dir if p instanceof jsnake.player.RemotePlayer
		# start
		data = get @players, @foods
		# TODO: 3秒待つことで、Client側のセットアップが終割ったと仮定。
		# あまりに決め打ちすぎるので、どうにかする。
		setTimeout () ->
			for player in players
				player.socket.call "start", data
		, 3000
		null
			
	update: () ->
		p.update() for p in @players
		if @span() > 100
			@updateField()
			@span = jsnake.timer.watch()
			for player in @players
				player.socket.call "update", (get @players, @foods)
		null


#-----------------------------------

# ## Exports

jsnake.core =
	Input: Input
	Timer: Timer
	OfflineModel: OfflineModel
	ClientModel: ClientModel
	ServerModel: ServerModel






