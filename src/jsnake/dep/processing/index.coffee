
# ## Dependencies
# - jsnake
# - jsnake.component
# - jsnake.player


@jsnake.dep.processing = 

	SNAKE_COLOR: do ->
		ID = jsnake.player.ID
		r = {}
		r[ID.A] = head: [200, 0, 0], body: [200, 50, 50]
		r[ID.B] = head: [0, 200, 0], body: [50, 200, 50]
		r[ID.C] = head: [0, 0, 200], body: [50, 50, 200]
		r[ID.D] = head: [200, 200, 0], body: [200, 200, 50]
		r

	FOOD_COLOR: do ->
		{TYPE} = jsnake.component.Food
		r = {}
		r[TYPE.INC] = [255, 0, 0]
		r[TYPE.DEC] = [0, 0, 255]
		r


	setupView: (canvas) ->
		PF.setup canvas, new jsnake.dep.processing.scene.GameStart





