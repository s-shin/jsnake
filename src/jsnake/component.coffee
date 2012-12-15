# general components used in the game

IS_NODE = exports? and module? and module.exports?

# ## Dependencies

if IS_NODE
	_ = require "underscore"
	jsnake = require "./jsnake"
	require "./util"
else
	_ = @_
	jsnake = @jsnake


{CELL_NUM} = jsnake
{Serializer} = jsnake.util

#-----------------------------------

DIRECTION =
	UP: 0, RIGHT: 1, DOWN: 2, LEFT: 3


# ## Position Class
class Position extends Serializer.Interface

	constructor: (@x, @y) ->

	isSame: (p) ->
		@x is p.x and @y is p.y
	
	move: (dir, isReverse=false) ->
		s = if isReverse then -1 else 1
		switch dir
			when DIRECTION.UP then @y -= s
			when DIRECTION.RIGHT then @x += s
			when DIRECTION.DOWN then @y += s
			when DIRECTION.LEFT then @x -= s
		@

	# detect the direction from `p1` to `p2`
	@detectDirection = (p1, p2) ->
		dx = p2.x - p1.x
		dy = p2.y - p1.y
		if (dx isnt 0 and dy isnt 0) or dx is dy
			return null
		else if dx is 0
			return if dy > 0 then DIRECTION.DOWN else DIRECTION.UP
		else if dy is 0
			return if dx > 0 then DIRECTION.RIGHT else DIRECTION.LEFT
		else
			return null
			
	detectDirection: (p) ->
		Position.detectDirection @, p

	clone: () ->
		new Position @x, @y
	
	rand = (x) -> Math.floor Math.random() * x
	
	random: (w, h) ->
		@x = rand w
		@y = rand h
		@
		
	set: (p) ->
		@x = p.x
		@y = p.y
		@

	serialize: () -> [@x, @y]
	deserialize: (data) -> [@x, @y] = data; @


# ## Snake Class
class Snake extends Serializer.Interface

	# initialized with `dir`, (`x`, `y`), `len`.
	constructor: (@dir, x, y, len=1) ->
		@body = []
		pos = new Position x, y
		i = 0; while i++ < len
			@body.unshift pos
			pos = pos.clone().move @dir
		@isLive = true

	direct: (@dir) -> 
	
	eat: (type) ->
		{TYPE} = jsnake.component.Food
		len = @body.length
		if len is 1
			if type is TYPE.DEC
				@isLive = false
			else
				@body.push(@body[0].clone().move @dir, true)
		else
			if type is TYPE.DEC
				@body.pop()
			else
				t = @body[len-1] # current last
				@body.push(t.clone().move @body[len-2].detectDirection(t))
		null

	update: () ->
		len = @body.length
		if len is 0
			return
		if len is 1
			@body[0].move @dir
		else
			# delete last, append head
			@body.unshift @body.pop().set(@body[0]).move(@dir)
		null

	serialize: () ->
		body: (p.serialize() for p in @body)
		dir: @dir
		isLive: @isLive

	deserialize: (data) ->
		@body = ((new Position).deserialize b for b in data.body)
		@dir = data.dir
		@isLive = data.isLive
		@


# ## Food Class
class Food extends Position

	@TYPE =
		INC: 1, DEC: 2

	# - `num` [Number] is [1-5]
	@getPreset = (num) ->
		{Food} = jsnake.component
		{INC, DEC} = Food.TYPE
		{X, Y} = jsnake.CELL_NUM
		[HX, HY] = (Math.floor a for a in [X/2, Y/2])
		[HHX, HHY] = (Math.floor a for a in [HX/2, HY/2])
		foods = []
		switch num
			when 1
				foods.push new Food INC, HX, HY
			when 2
				foods.push new Food INC, HX - HHX, HY
				foods.push new Food INC, HX + HHX, HY
			when 3
				foods.push new Food DEC, HX, HY
				foods.push new Food INC, HX - HHX, HY
				foods.push new Food INC, HX + HHX, HY
			when 4
				foods.push new Food INC, HX, HY + HHY
				foods.push new Food INC, HX, HY - HHY
				foods.push new Food DEC, HX - HHX, HY
				foods.push new Food DEC, HX + HHX, HY
			when 5
				foods.push new Food INC, HX, HY
				foods.push new Food INC, HX, HY + HHY
				foods.push new Food INC, HX, HY - HHY
				foods.push new Food DEC, HX - HHX, HY
				foods.push new Food DEC, HX + HHX, HY
			else
				console.error "no such preset"
		foods

	constructor: (@type, x, y) -> super x, y

	serialize: () -> [@type, @x, @y]
	deserialize: (data) -> [@type, @x, @y] = data; @


# ## Field Class
class Field
	constructor: (@width=CELL_NUM.X, @height=CELL_NUM.Y, @isWall=false) ->

	isOutside: (p) ->
		p.x >= @width or p.x < 0 or p.y >= @height or p.y < 0

	# - `snakes` [Array(Snake)]
	# - `foods` [Array(Food)]
	update: (snakes, foods) ->
		# pの位置にあるsnakeを取得
		getSnake = (p) ->
			for snake in snakes
				return snake if _(snake.body).any (b) -> b.isSame p
			null
		# pの位置にあるfoodを取得
		getFood = (p) ->
			for food in foods
				return food if p.isSame food
			null
		# 新しいfoodの作成
		createFood = (type) =>
			food = new Food type
			loop
				food.random @width, @height
				break unless getSnake food || getFood food
			food

		### ↑の代わりにこっちを使う？
		@createNewFood: (type, bodies, foods) ->
			food = new Food type
			food.random()
			food.random() while ->
				_.chain([bodies, foods]).flatten().any (p) -> p.isSame food
			food
		###

		# NOTE: 処理を一度のループで行うと先の方と後のほうで状態が
		# 変わってしまうので判定ごとに個別のループで行う。
	
		# Snakeの単純な移動（場外にも出うる）
		for snake in snakes
			snake.update()
			
		# 食べたか判定。Snakeの当たり判定の前に行う。
		eatenFoods = []
		for snake in snakes
			head = snake.body[0]
			if food = getFood head
				# ここでsnakeの長さを変更してよい
				snake.eat food.type
				# foodは後
				eatenFoods.push food
				continue
		for food in eatenFoods
			# 現在の`foods`から食べられた`food`を取り除く
			foods = _(foods).without food
			# 食べられた`food`と同じタイプの新しい`Food`を生成
			foods.push createFood(food.type)
			# NOTE: `foods`の状態をガンガン変更しているが、それで正しい

		# Snakeの当たり判定
		for snake in snakes
			# 死んでたらスキップ
			if not snake.isLive
				continue
		
			head = snake.body[0]
			# 場外に出たかどうか。壁ありなら死亡。なしなら逆から出てくる。
			if @isWall
				# 場外死亡なら`head`だけ見れば良い
				if @isOutside head
					snake.isLive = false
					continue # 次のsnake
			else
				# 位置調整をする
				for b in snake.body
					if @isOutside b
						b.x = (b.x + @width) % @width
						b.y = (b.y + @height) % @height
						break # 場外に出るのは高々１つなのでbreak
			# `head`の位置に`head`以外のbodyがあったら衝突で死亡
			# NOTE: `_.any`はtrueなところで止まる
			isDead = _(snakes).any (s) -> # 各snakeが持つ
				_(s.body).any (b) -> # bodyのセルについて
					return false if b is head # `head`自身なら無視するが
					b.isSame head # そうでないもので場所が一致したならアウト
			snake.isLive = not isDead if isDead
					
		# 新しい状態の`snakes`と`foods`を返す
		[snakes, foods]


#-----------------------------------

# ## Exports

jsnake.component =
	DIRECTION: DIRECTION
	Snake: Snake
	Food: Food
	Field: Field

