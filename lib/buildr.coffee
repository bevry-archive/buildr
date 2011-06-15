# Requirements
sys = require 'sys'
fs = require 'fs'
path = require 'path'
util = require 'bal-util'
exec = require('child_process').exec
deps = require __dirname+'/dep.js'

# Declare
class Buildr
	# Components
	components:
		css: require __dirname+'/css.coffee'
		js: require __dirname+'/js.coffee'
		img: require __dirname+'/img.coffee'
	
	# Tasks
	tasks:
		check: (args...) ->
			
	# Run a task
	runTask: (taskName, args, next) ->
		# Prepare
		args or= []

		# Tasks
		tasks = new util.Group (err) ->
			next err
		
		# Run task for each component which supports it
		for own componentName, component of @components
			if component[taskName]?
				tasks.total++
				component[taskName].apply(component,args);
	