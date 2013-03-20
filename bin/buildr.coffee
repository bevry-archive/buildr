#!/usr/bin/env coffee

# Requires
cson = require 'cson'
fs = require 'fs'
path = require 'path'
buildr = require __dirname+'/../lib/buildr'
optimist = require 'optimist'

# Argument parsing
argv = optimist.options('file', {
  alias: 'f',
  default: 'buildr.cson'
}).argv;

filename = path.resolve argv.file

#Preprocessors
preprocessors = [
    (data) ->
        new_data = data
        p = /##def\s+(\w+)\s*"(.*?)"/g
        while m = p.exec data
            console.log "--> " + m[0]
            new_data = new_data.replace RegExp(m[1], 'g'), m[2]
        new_data
]
data = ''
fs.exists filename, (exists) ->
    if exists
        fs.readFile filename, (err,d) ->
            throw err if err
            data = d.toString()

            console.log "Preprocessing configuration file..."
            for p in preprocessors
                data = p data
            console.log "Preprocessed."

            # Parse the config file
            cson.parse data, (err,config) ->
                throw err if err
                myBuildr = buildr.createInstance(config)
                myBuildr.process (err) ->
                    throw err if err
    else
        console.error "Configuration file not found: #{filename}"
