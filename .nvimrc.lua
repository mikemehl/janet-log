local overseer = require("overseer")
local janet_repl = overseer.new_task({
	cmd = 'janet -e "(import spork/netrepl) (netrepl/server)"',
	name = "janet-netrepl",
})

janet_repl:start()
