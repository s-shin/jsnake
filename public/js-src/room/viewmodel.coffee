
# ## ViewModels for Knockout.js
# depending: room.model

# ### setupUI
setupUI = () ->
	$(".spinner").each () ->
		t = $ @
		return if t.data "spinner"
		t.attr "data-spinner", true
		new Spinner
			lines: 11
			length: 4
			width: 2
			radius: 4
			color: "#FFF"
			className: "__spinner__"
			top: 0, left: 0
		.spin this

	$(".show-tooltip").tooltip()


# ### phase ViewModel
# This phase is global because in whichever phase the current phase can be
# changed. Changing the current phase in phases, we use `phase.change`
# (do not set into `phase.current` directly).
phase =
	initialize: (firstPhase) ->
		@current = ko.observable firstPhase
		ko.applyBindings @
		setupUI()
	change: (p) ->
		@current p
		setupUI()


class BasePhase

	constructor: (Phase) ->
		@Phase_ = Phase

	is: (Phase) -> @Phase_ is Phase
		

class EntryPhase extends BasePhase

	constructor: () ->
		super EntryPhase
		@isLoading = ko.observable false
		@serverAddress = ko.observable ""
		@playerName = ko.observable ""
		@error = ko.observable ""

	isError: () ->
		@error().length > 0

	isValid: () ->
		@serverAddress().length > 0 && @playerName().length > 0

	entry: () ->
		@error ""
		@isLoading true
		room.model.entry @serverAddress(), @playerName(), (err) =>
			@isLoading false
			return @error err if err
			phase.change new RoomPhase


class RoomPhase extends BasePhase

	class Player
		constructor: (name, isReady) ->
			@name = ko.observable name
			@isMe = name is room.model.playerName
			@isReady = ko.observable isReady
			@isReadyBusy = ko.observable false

		isActive: () -> @name()?

		toggleReadyState: () ->
			@isReadyBusy true
			room.model.toggleReadyState()

	constructor: () ->
		super RoomPhase
		@players = ko.observableArray()
		@serverAddress = room.model.serverAddress
		room.model.addOnUpdatePlayers (players) => @updatePlayers(players)
		room.model.addOnSetupGame () -> phase.change new GamePhase()
		room.model.updatePlayers()

	exit: () ->
		room.model.exit (err) ->
			unless err
				phase.change new EntryPhase()

	updatePlayers: (players) ->
		@players _(players).map (p) -> new Player p.name, p.isReady


class GamePhase extends BasePhase

	constructor: () ->
		super GamePhase
		@isLoading = ko.observable true
		setTimeout () =>
			@isLoading false
			room.model.setupGame()
		, 1000



#-------------------------------------------

# Exports

@room.viewmodel =
	phase: phase
	EntryPhase: EntryPhase
	RoomPhase: RoomPhase
	GamePhase: GamePhase
	setup: () ->
		phase.initialize new EntryPhase
	
