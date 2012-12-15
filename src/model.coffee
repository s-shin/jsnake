
winston = require "winston"
_ = require "underscore"
util = require "util"

# to be replaced with real database
DB = {}
# DB =
#   roomName:
#     created
#     players:
#       name:
#       isReady:
#       isSetupFinish:

module.exports = class Model

	jsnake = require "./jsnake/jsnake"

	# errors
	ERROR =
		NOT_EXISTS: "not exists"
		EXISTS: "already exists"
		TOO_MANY_PLAYERS: "too many players"
		TOO_FEW_PLAYERS: "too few players"
		INTERNAL: "internal error"

	# - `fn(err)`
	constructor: (name, fn) ->
		if DB[name]?
			@room = DB[name]
		else
			@room = DB[name] =
				created: Date.now()
				players: []
		fn null

	# - `fn(err)`
	entryPlayer: (name, id, fn) ->
		ps = @room.players
		return fn ERROR.EXISTS if _(ps).any (p) -> p.name is name
		return fn ERROR.TOO_MANY_PLAYERS if ps.length >= jsnake.MAX_PLAYER_NUM
		ps.push
			name: name
			isReady: false
			isSetupFinish: false
			playerId: id
		fn null


	# - `fn(err, areAllReady)`
	togglePlayerReadyState: (name, fn) ->
		player = _(@room.players).find (p) -> p.name is name
		return fn ERROR.NOT_EXISTS if not player?
		player.isReady = not player.isReady
		return fn null, false if @room.players.length < 2
		fn null, _(@room.players).all (p) -> p.isReady

	# - `fn(err)`
	removePlayer: (name, fn) ->
		player = _(@room.players).find (p) -> p.name is name
		return fn ERROR.NOT_EXISTS if not player?
		@room.players = _(@room.players).without player
		fn null

	getPlayers: (fn) ->
		fn null, @room.players

	getPlayerNum: (fn) ->
		@getPlayers (err, players) ->
			fn null, players.length

	togglePlayerSetupFinish: (name, fn) ->
		player = _(@room.players).find (p) -> p.name is name
		return fn ERROR.NOT_EXISTS if not player?
		player.isSetupFinish = not player.isSetupFinish
		fn null, _(@room.players).all (p) -> p.isSetupFinish
		

