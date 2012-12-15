{run2} = require "./cake-util"

task "start", "start application", start = ->
	run2 "redis-server"
	run2 "node app"

task "build", "build all scripts", build = ->
	run2 "coffee -c -o lib/ src/"
	run2 "coffee -c app.coffee"
	run2 "coffee -c -o public/js/ public/js-src/"

task "watch", "watch all scripts", watch = ->
	run2 "coffee -c -w -o lib/ src/"
	run2 "coffee -c -w app.coffee"
	run2 "coffee -c -w -o public/js/ public/js-src/"

task "devel", "development environment", devel = ->
	#watch()
	#run2 "redis-server"
	#run2 "node-dev app"
	run2 "node-dev --debug app"
	run2 "node-inspector"



