
{DIRECTION} = jsnake.component
{LocalPlayer} = jsnake.player

class OfflinePlayer1 extends LocalPlayer

	ax = ay = null
	if window
		window.addEventListener "devicemotion", (event) ->
			{x, y} = event.accelerationIncludingGravity
			switch window.orientation
				when 0 then [ax, ay] = [x, y]
				when 90 then [ax, ay] = [-y, x]
				when -90 then [ax, ay] = [y, -x]
				else [ax, ay] = [-x, -y]

	onInput: (p, key) ->
		DIR = DIRECTION
		dir = null
		if ax isnt null and ay isnt null
			if ay > 3
				dir = DIR.UP
			else if ax > 3
				dir = DIR.RIGHT
			else if ay < -3
				dir = DIR.DOWN
			else if ax < -3
				dir = DIR.LEFT
		else
			keys = [p.UP, p.RIGHT, p.DOWN, p.LEFT]
			dirs = [DIR.UP, DIR.RIGHT, DIR.DOWN, DIR.LEFT]
			for i in [0..3]
				if key.isPressed keys[i]
					dir = dirs[i]
		@input dir


jsnake.dep.processing.player =
	OfflinePlayer1: OfflinePlayer1





