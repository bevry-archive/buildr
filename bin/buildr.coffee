#!/usr/bin/env coffee

# Requires
cson = require 'cson'
fs = require "fs"
buildr = require __dirname+'/../lib/buildr.coffee'
cwd = process.cwd()

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
fs.readFile "#{cwd}/buildr.cson", (err,d) ->
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
