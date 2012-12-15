
class Model

	constructor: () ->
		@playerName = null
		@serverAddress = null
		@onUpdatePlayers = []
		@onSetupGame = []

	getHandlers: () ->
		T = @

		updatePlayers: ([players]) ->
			T.players = players # TODO: rethink the way
			_(T.onUpdatePlayers).each (fn) -> fn players

		setupGame: ([], fn) ->
			_(T.onSetupGame).each (fn) -> fn()

	addOnUpdatePlayers: (fn) ->
		@onUpdatePlayers.push fn

	addOnSetupGame: (fn) ->
		@onSetupGame.push fn


	# ### Model.entry
	# - `serverAddress` [String] is the server address to be connecting.
	# - `name` [String] is the user name to be appended.
	# - `fn` [Function] is the callback.
	#    + `err` [Function] is error. It is `null` when no error occured.
	entry: (serverAddress, name, fn) ->
		T = @

		socket = io.connect serverAddress

		socket.on "error", () ->
			socket.diconnect()
			fn "Connecting to #{serverAddress} failed."

		socket.on "connect", () ->
			socket.on "setupFinish", onSetupFinish
					
		onSetupFinish = () ->
			remote = new Remote socket
			remote.call "entry", [name], ([err]) ->
				return fn err if err
				T.remote = remote
				T.playerName = name
				T.serverAddress = serverAddress
				T.remote.register T.getHandlers()
				fn null
			

	# request latest information about players to the server.
	updatePlayers: () ->
		@remote.call "getPlayers"

	toggleReadyState: () ->
		@remote.call "toggleReadyState", [@playerName], ([err]) ->
			console.log "room.model.toggleReadyState: #{err}" if err


	exit: (fn) ->
		@remote.call "exit", [@playerName], ([err]) ->
			fn err if err
			fn null

	setupGame: () ->
		jsnake.prepare()
		{SocketByRemote} = jsnake.socket
		{OfflinePlayer1} = jsnake.dep.processing.player
		players = []
		for p in @players
			if p.name is @playerName
				players.push new OfflinePlayer1 p.playerId 
		# TODO: OK?
		jsnake.setupClient \
			new SocketByRemote(@remote),
			players,
			(() -> console.log "end"),
			(() =>
				jsnake.dep.processing.setupView $("canvas")[0]
				@remote.call "setupGameFinish", [@playerName])

	
#------------------------------------------
# Exports

@room.model = new Model




