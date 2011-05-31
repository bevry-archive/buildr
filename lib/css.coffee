# Require
util = require 'bal-util'

# Buildr Image Component
module.exports =
	
	# Compress a ss file
	compressFile: (filePath, next) ->
		# Log
		console.log("Compress: "+filePath);

		# Compress

		# Forward
		return next false

	# Compress a series of css files
	compress: ({files},next) ->
		# Prepare
		files or= []
	
		# Compress Files
		util.scandirSafe(
			# Directory
			files
			# File Action
			(filePath,callback) =>
				@compressFile filePath, callback
			# Dir Action
			false
			# Complete Action
			(err) ->
				next err
		)
	
	# Pack a series of css files together
	pack: ({files},next) ->
		# Prepare
		files or= []

	# Merge a series of css files together
	merge: ({files,del},next) ->
		# Prepare
		files or= []
		del ?= false

