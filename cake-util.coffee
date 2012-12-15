{spawn, exec} = require "child_process"

# ## Print Functions

# ANSI terminal escape sequences
styles =
	bold: "\x1b[0;1m"
	green: "\x1b[0;32m"
	reset: "\x1b[0m"
	red: "\x1b[0;31m"	

printToStdout = (s) -> process.stdout.write s
printToStderr = (s) -> process.stderr.write s

print = (str, style="", printFn=printToStdout) ->
	printFn style + str + styles.reset
	0
	
println = (str, args...) ->
	print str + "\n", args...

error = (str, style) ->
	print str, style, printToStderr
	1

errorln = (str, args...) ->
	error str + "\n", args...

# ## Command Functions

handleProc = (proc, onExit) ->
	println "[#{proc.pid}] started"
	proc.stdout.on "data", (data) -> print "[#{proc.pid}] #{data}"
	proc.stderr.on "data", (data) -> error "[#{proc.pid}] #{data}"
	proc.on "exit", (code) ->
		println "[#{proc.pid}] exited with #{code}"
		onExit(code) if onExit
	proc

run = (cmd, args, opts, onExit) ->
	p = spawn cmd, args, opts
	handleProc p, onExit

run2 = (cmd, opts, onExit) ->
	p = exec cmd, opts
	handleProc p, onExit
	
# ## Exports

module.exports =
	styles: styles
	print: print
	println: println
	error: error
	errorln: errorln
	handleProc: handleProc
	run: run
	run2: run2


