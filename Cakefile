fs = require 'fs'
CoffeeScript = require 'coffee-script'

task 'build', 'compile source files to javascript', (options) ->
  compile 'lib/buildr.coffee', false
  compile 'bin/buildr.coffee', true

task 'clean', 'delete compiled output', (options) ->
  fs.unlink 'lib/buildr.js'
  fs.unlink 'bin/buildr.js'

compile = (sourceFile, needShebang) ->
  fs.readFile sourceFile, 'utf8', (error, coffeeCode) ->
    throw error if error

    javaScript = CoffeeScript.compile(coffeeCode)
    javaScript = '#!/usr/bin/env node\n' + javaScript if needShebang

    outFile = sourceFile.replace '\.coffee', '.js'
    fs.writeFile outFile, javaScript, 'utf8', () ->
      console.log 'built ' + outFile + ' successfully.'
