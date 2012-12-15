winston = require "winston"
_ = require "underscore"
Model = require "./model"
Remote = require "./remote"
jsnake = require "./jsnake"


class User
	constructor: (@room, @remote, @model) ->
		remote.register @getHandlers()

	getHandlers: () ->
		T = @
	
		entry: ([name], fn) ->
			{player} = jsnake
			PLAYER_ID = [player.ID.A, player.ID.B, player.ID.C, player.ID.D]
			T.model.getPlayerNum (err, num) ->
				T.model.entryPlayer name, PLAYER_ID[num], (err) -> fn [err]
				null

		toggleReadyState: ([name], fn) ->
			T.model.togglePlayerReadyState name, (err, areAllReady) ->
				return fn [err] if err
				fn [null]
				T.room.updatePlayers()
				T.room.setupGame() if areAllReady

		getPlayers: () ->
			T.room.updatePlayers()

		exit: ([name], fn) ->
			T.model.removePlayer name, (err) ->
				return fn [err] if err
				fn [null]
				T.room.exit T

		setupGameFinish: ([name]) ->
			T.model.togglePlayerSetupFinish name, (err, allFinish) ->
				return console.log "ERROR: ", err if err
				T.room.startGame() if allFinish


	setupGame: () ->
		@remote.call "setupGame"

	# update players' infomation
	updatePlayer: () ->
		# send players in this room
		@model.getPlayers (err, players) =>
			return console.log "ERROR: ", err if err
			@remote.call "updatePlayers", [players]

	getRemote: () -> @remote


class Room

	MAX_PLAYER_NUM = 4

	constructor: (name) ->
		@model = new Model name, (err) =>
			if err
				console.error err
				console.trace()
		@users = []

	setup: (remote) ->
		@users.push (new User @, remote, @model)

	updatePlayers: () ->
		user.updatePlayer() for user in @users

	exit: (user) ->
		@users = _(@users).without user
		@updatePlayers()

	setupGame: () ->
		user.setupGame() for user in @users
		@model.getPlayers (err, players) =>
			return console.log "ERROR: ", err if err
			@jsnake = new Jsnake @users, players, () ->
				console.log "Game is end!!!" # TODO

	startGame: () ->
		@jsnake.start()
				

class Jsnake

	POS = do ->
		ID = jsnake.player.ID
		IP = jsnake.player.INITIAL_POSITION
		r = {}
		r[ID.A] = IP.LT
		r[ID.B] = IP.RB
		r[ID.C] = IP.RT
		r[ID.D] = IP.LB
		r

	constructor: (users, playersInfo, onEnd) ->
		jsnake.prepare()
		players = do ->
			for info, i in playersInfo
				new jsnake.player.RemotePlayer info.playerId, POS[info.playerId], 3,
					(new jsnake.socket.SocketByRemote users[i].getRemote())
		jsnake.setupServer players, (jsnake.component.Food.getPreset 5), onEnd

	# main loop
	start: () ->
		prev = Date.now()
		do -> do mainLoop = ->
			# update timer
			now = Date.now()
			jsnake.timer.update now - prev
			jsnake.model.update()
			prev = now
			# loop
			setTimeout mainLoop, 50
			#process.nextTick mainLoop


# ## Exports

module.exports = (app, io) ->
	
	createRoom = (name) ->
		room = new Room name
		io.of("/#{name}").on "connection", (socket) ->
			console.log "createRoom: on connection in #{name}"
			room.setup (new Remote socket)
			socket.emit "setupFinish"
	
	createRoom "test"


