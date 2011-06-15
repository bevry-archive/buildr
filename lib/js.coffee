# Require
util = require 'bal-util'
jshint = require('jshint').JSHINT
uglify = require 'uglify-js'
jsp = uglify.parser
pro = uglify.uglify
cwd = process.cwd()

# Buildr JS Component
module.exports =
	
	# Check js data
	compressData: (src,next) ->
		# Prepare
		foundError = false
		
		# Output
		jshint(fileData,config.check.jsOptions)
		result = jshint.data()

		# Result
		if !result.errors or !result.errors.length then return
		
		# Log
		console.log filePath

		# Output
		result.errors.forEach (error) ->
			if !error or !error.raw then return
			foundError = true
			console.log(
				'\tLine '+error.line+':'+
				' '+error.raw.replace(/\{([a-z])\}/,function(a,b){
					return error[b]||a;
				})+
				(error.evidence ? '\n\t'+error.evidence.replace(/^\s+/,'') : '')+
				'\n'
			)
		
		# Fail?
		if foundError
			process.exit()
	
		# Forward
		return next false
	
	# Compress a js file
	checkFile: (fileFullPath,fileRelativePath,next) ->
		# Log
		console.log 'Compressing:', filePath

		# Read
		fs.readFile fileFullPath, (err,data) =>
			# Error
			if err then return next err
			
			# Compress
			@checkData src.toString(), (err) =>
				# Forward
				return next err

	# Compress a series of js files
	check: ({files,dir},next) ->
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
					@checkFile fileFullPath,fileRelativePath,next
				# Dir Action
				false
				# Complete Action
				(err) ->
					next err
			)


	# Compress js data
	compressData: (src,next) ->
		# Compress
		ast = jsp.parse(src) # parse code and get the initial AST
		ast = pro.ast_mangle(ast) # get a new AST with mangled names
		ast = pro.ast_squeeze(ast) # get an AST with compression optimizations
		out = pro.gen_code(ast) # compressed code here
	
		# Forward
		return next false, out
	
	# Compress a js file
	compressFile: (fileFullPath,fileRelativePath,next) ->
		# Log
		console.log 'Compressing:', filePath

		# Read
		fs.readFile fileFullPath, (err,data) =>
			# Error
			if err then return next err
			
			# Compress
			@compressData src.toString(), (err,out) =>
				# Write
				fs.writeFile fileFullPath, out, (err) ->
					# Error
					if err then return next err

					# Forward
					return next false, out

	# Compress a series of js files
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
		

	# Pack a js file
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
	
	# Pack a series of js files together
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


	# Merge a series of js files together
	merge: ({files,out,del},next) ->
		# Prepare
		files or= []
		del ?= false

		# For now just pack
		@pack {files,out,del}, next

