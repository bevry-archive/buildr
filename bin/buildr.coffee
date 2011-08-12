#!/usr/bin/env coffee

# Error
console.log 'Command line buildr may not currently work due to this bug: https://github.com/balupton/buildr.npm/issues/8'

# Requires
cson = require 'cson'
buildr = require __dirname+'/../lib/buildr.coffee'
cwd = process.cwd()

# Parse the config file
cson.parseFile "#{cwd}/buildr.cson", (err,config) ->
	throw err if err
	myBuildr = buildr.createInstance(config)
	myBuildr.process (err) ->
		throw err if err
