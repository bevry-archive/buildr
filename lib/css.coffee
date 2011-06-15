# Require
util = require 'bal-util'
cleanCSS = require 'clean-css'
cwd = process.cwd()

# Buildr CSS Component
module.exports =
	
	# Compress css data
	compressData: (src,next) ->
		# Compress
		out = cleanCSS.process src

		# Forward
		return next false, out
	
	# Compress a css file
	compressFile: (fileFullPath,fileRelativePath,next) ->
		# Log
		console.log 'Compressing:', filePath

		# Read
		fs.readFile fileFullPath, (err,data) =>
			# Error
			if err then return next err
			
			# Compress
			@compressData data.toString(), (err,out) =>
				# Write
				fs.writeFile fileFullPath, out, (err) ->
					# Error
					if err then return next err

					# Forward
					return next false, out

	# Compress a series of css files
	compress: ({files,dir},next) ->
		# Prepare
		files or= []
		dir or= cwd

		# Adjust paths
		util.expandPaths files, dir, (err,files) ->
			# Error
			if err then return next err

			# Compress Files
			util.scan(
				# List
				files
				# File Action
				(fileFullPath,fileRelativePath,next) =>
					@compressFile fileFullPath,fileRelativePath,next
				# Dir Action
				false
				# Complete Action
				(err) ->
					next err
			)
		
	# Pack a css file
	packFile: (fileFullPath,fileRelativePath,next) ->
		# Log
		console.log 'Packing:', filePath

		# Read
		fs.readFile fileFullPath, (err,data) ->
			# Error
			if err then return next err
			
			# Compress
			src = data.toString()

			# Forward
			return next false, src
	
	# Pack a series of css files together
	pack: ({files,dir,out},next) ->
		# Prepare
		files or= []
		dir or= cwd
		urls = []
		count = 0
		template = '@import url(%URL%);\n'

		# Adjust paths
		util.expandPaths files, dir, (err,files) ->
			# Error
			if err then return next err

			# Compress Files
			util.scan(
				# List
				files
				# File Action
				(fileFullPath,fileRelativePath,next) =>
					++count
					(=> return (index) => @packFile fileFullPath, fileRelativePath, (err,src) ->
						# Error
						if err then return next err

						# Ammend
						urls[index] = src
					)(count)
				
				# Dir Action
				false
				# Complete Action
				(err) ->
					# Error
					if err then return next err
					
					# Prepare
					result = ''

					# Ammend
					for url in urls
						result += template.replace '%URL%', filePath
					
					# Write
					fs.writeFile out, result, (err) ->
						# Error
						if err then return next err
					
						# Forward
						next false
			)

	# Merge a series of css files together
	merge: ({files,out,del},next) ->
		# Prepare
		files or= []
		del ?= false

		# For now just pack
		@pack {files,out,del}, next

