
{CELL_NUM} = jsnake
{SNAKE_COLOR, FOOD_COLOR} = jsnake.dep.processing

#-----------------------------------

WIDTH = 400
HEIGHT = 300
FPS = 30 # frames/s
MSPF = 1000 / 30 # ms/frames
CELL_WIDTH = WIDTH / CELL_NUM.X
CELL_HEIGHT = HEIGHT / CELL_NUM.Y

class BaseScene extends PF.Scene

	setup: (p) ->
		@previousFrameCount = p.frameCount		

	update: (p) ->
		jsnake.timer.update (p.frameCount - @previousFrameCount) * MSPF
		@previousFrameCount = p.frameCount


class GameStart extends BaseScene
	setup: (p) ->
		super p
		p.frameRate FPS
		p.size WIDTH, HEIGHT
		@count = 3
		return new GameMain

	###
	update: (p) ->
		if p.frameCount % FPS is 0
			@count--
			return new GameMain if @count is 0
		null

	draw: (p) ->
		p.background 255
		p.text @count.toString
		null
	###


class GameMain extends BaseScene

	update: (p) ->
		super p
		jsnake.input.update p, @key
		jsnake.model.update()
		null

	draw: (p) ->
		p.background 255

		drawCellRect = (pos) ->
			p.rect pos.x * CELL_WIDTH, pos.y * CELL_HEIGHT, CELL_WIDTH, CELL_HEIGHT

		drawCellCircle = (pos) ->
			p.ellipseMode p.CORNER
			p.ellipse pos.x * CELL_WIDTH, pos.y * CELL_HEIGHT, CELL_WIDTH, CELL_HEIGHT

		drawSnake = (player) ->
			color = SNAKE_COLOR[player.id]
			p.noStroke()
			for b, i in player.snake.body
				if i is 0
					p.fill color.head...
				else
					p.fill color.body...
				drawCellRect b

		drawFood = (food) ->
			p.noStroke()
			p.fill FOOD_COLOR[food.type]...
			drawCellCircle food

		(drawSnake player if player.snake.isLive) for player in jsnake.model.getPlayers()
		drawFood food for food in jsnake.model.getFoods()
		null


###
class GameOver extends PF.Scene
	update: (p) ->
		return new GameStart if PF.key.isPressed " "
		null

	draw: (p) ->
		p.background 255
		p.fill 255, 0, 0
		p.textFond "Arial", 20
		s = "Game Over"
		w = p.textWidth s
		p.text s, (WIDTH-w)/2, HEIGHT/2
		s = "Press space key to restart"
		w = p.textWidth s
		p.text s, (WIDTH-w)/2, HEIGHT/2 + 30
		null
###

#-----------------------------------

# ## Exports

jsnake.dep.processing.scene =
	GameStart: GameStart





