# Require
util = require 'bal-util'
pulverizr = null

# Buildr Image Component
module.exports =
	
	# Compress a image file
	compressFile: (filePath, next) ->
		# Compress
		console.log("Compressed: "+filePath);
		pulverizr.compress(filePath,{
			"quiet": true
		});

		# Forward
		return next false

	# Compress a series of image files
	compress: ({files},next) ->
		# Load Pulverizr
		try {
			pulverizr = require 'pulverizr-bal'
		}
		catch ( e ) {
			console.log 'Failed to load the pulverizr-bal package. Images will not be compressed.'
			return next false
		}

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