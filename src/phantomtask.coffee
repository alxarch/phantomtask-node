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
		@inject = []
	inject: (script) ->
		@inject.push script
		@
	add: (task, options) ->
		@tasks.push
			path: task
			options: assign {}, options
		@
	run: (src, callback = ->) ->
		args = []

		for own key, value of pick options, PHANTOM_ARGUMENTS
			args.push "--#{S(key).dasherize().toString()}"
			args.push value
		args.push phantomtask
		if options.parallel
			args.push "-p"
		for task in @tasks
			args.push "-t"
			args.push "#{task.path}#{delimiter}#{JSON.stringify task.options}"
		for script in @inject
			args.push "-i"
			args.push script
		args.push src
		p = spawn phantomjs, args
		p.on "exit", (code) ->
			error = null
			unless code is 0
				error = new Error "Phantomjs exited with code: #{code}"
			callback error
		@

module.exports = PhantomTask
