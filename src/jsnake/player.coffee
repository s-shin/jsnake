IS_NODE = exports? and module? and module.exports?

# ## Dependencies
# - `jsnake`

if IS_NODE
	jsnake = require "./jsnake"
	require "./core"
	require "./component"
	require "./util"
else
	jsnake = @jsnake


{CELL_NUM} = jsnake
{Input} = jsnake.core
{Snake, DIRECTION} = jsnake.component
{Serializer, implement, to_be_implemented} = jsnake.util

#----------------------------------

ID =
	A: 0, B: 1, C: 2, D: 3

INITIAL_POSITION =
	LT: 0, RB: 1, RT: 2, LB: 3
	

# ## Player Class (base)
# the base class of `jsnake.player.*`
class Player
	implement @, Serializer.Interface

	createSnake = (id, pos, len) ->
		P = INITIAL_POSITION; C = CELL_NUM; D = DIRECTION
		switch pos
			when P.RT then new Snake D.DOWN, C.X-1, 0, len
			when P.RB then new Snake D.LEFT, C.X-1, C.Y-1, len
			when P.LB then new Snake D.UP, 0, C.Y-1, len
			when P.LT then new Snake D.RIGHT, 0, 0, len

	constructor: (@id, pos, len) ->
		@snake = createSnake @id, pos, len
	
	update: () -> to_be_implemented()

	serialize: () -> [@id, @snake.serialize()]
	deserialize: (data) ->
		[@id, snake] = data
		@snake = (new Snake()).deserialize snake
		@


# ### UserPlayer
# input-driven player
class UserPlayer extends Player
	input: (dir) -> @dir = dir
	
	update: () ->
		@snake.direct @dir if @dir?
	

# ### RemotePlayer
class RemotePlayer extends UserPlayer
	constructor: (args..., @socket) ->
		super args...


# ### LocalPlayer Class (abstract)
class LocalPlayer extends UserPlayer
	implement @, Input.Interface

	constructor: (args...) ->
		super args...
		jsnake.input.add @
	
	# convert `raw` to `DIRECTION` and call `input`
	onInput: (raw...) -> to_be_implemented()


# ### ComputerPlayer Class
class ComputerPlayer extends Player

	update: () ->
		# to determine the direction

	
#-----------------------------------

# ## Exports

jsnake.player = 
	Player: Player
	UserPlayer: UserPlayer
	RemotePlayer: RemotePlayer
	LocalPlayer: LocalPlayer
	ComputerPlayer: ComputerPlayer
	ID: ID
	INITIAL_POSITION: INITIAL_POSITION
	
