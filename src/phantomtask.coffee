{spawn} = require "child_process"
{assign, omit, pick} = require "lodash"
{delimiter} = require "path"
phantomjs = require("phantomjs").path
phantomtask = require.resolve "phantomtask/bin/phantomtask"
S = require "string"

PHANTOM_ARGUMENTS = [
	"webSecurity"
	"loadImages"
	"diskCache"
	"cookiesFile"
]

class PhantomTask
	constructor: (options) ->
		@options = assign {}, options
		@tasks = []
		@scripts = []

	inject: (script) ->
		@scripts.push script
		@
	add: (path, description = "", options = {}) ->
		@tasks.push {path, description, options}
		@
	run: (src, callback = ->) ->
		if @process?
			throw new Error "Task already running. (pid: #{@process.pid})"

		args = []

		for own key, value of pick @options, PHANTOM_ARGUMENTS
			args.push "--#{S(key).dasherize().toString()}"
			args.push value

		args.push phantomtask
		
		if @options.parallel
			args.push "-p"

		for task in @tasks
			args.push "-t"
			args.push task.path
			if task.description
				args.push "-d"
				args.push task.description
			if task.options
				args.push "-o"
				args.push JSON.stringify task.options

		for script in @scripts
			args.push "-i"
			args.push script

		
		if src
			args.push src

		@process = spawn phantomjs, args
		@process.stdout.pipe (@options.stdout or process.stdout)
		@process.stderr.pipe (@options.stderr or process.stderr)
		@process.on "exit", (code) ->
			@process = null
			error = null
			unless code is 0
				error = new Error "Phantomjs exited with code: #{code}"
			callback error
		@

module.exports = PhantomTask
