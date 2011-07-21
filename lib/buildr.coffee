# Requires
fs = require 'fs'
path = require 'path'
util = require 'bal-util'
coffee = require 'coffee-script'
less = require 'less-bal'
pulverizr = require 'pulverizr-bal'
jshint = require('jshint').JSHINT
uglify = require 'uglify-js'
jsp = uglify.parser
pro = uglify.uglify
cwd = process.cwd()


# =====================================
# Buildr

# Define
class Buildr

	# Configuration
	config: {
		# Paths
		srcPath: false # String
		outPath: false # String or false

		# Loaders
		srcLoaderHeader: false # String or false
		srcLoaderPath: false # String or false

		# Bundling
		bundleScripts: false # Array or true or false
		bundleStyles: false # Array or true or false
		bundleScriptPath: false # String or false
		bundleStylePath: false # String or false
		deleteBundledOutFiles: true # true or false

		# Checking
		checkScripts: false # Array or true or false
		jshintOptions: false # Object or false
		
		# Compression
		compressOutFiles: true # true or false
	}

	# Files to clean
	filesToClean: []

	# Error
	errors: []

	# Constructor
	constructor: (@config) ->

	# =====================================
	# Actions

	# Process
	process: (next) ->
		# Check configuration
		@checkConfiguration (err) =>
			return next err	 if err

			# Check files
			@checkFiles (err) =>
				return next err	 if err

				# Copy srcPath to outPath
				@cpSrcToOut (err) =>
					return next err	 if err

					# Generate files
					@generateFiles (err) =>
						return next err	 if err

						# Clean outPath
						@cleanOutPath (err) =>
							return next err	 if err

							# Compress outPath
							@compressOutPath (err) =>
								next err
		
	# Check Configuration
	# next(err)
	checkConfiguration: (next) ->
		# Check
		return next new Error('srcPath is required')  unless @config.srcPath

		# Prepare
		tasks = new util.Group (err) ->
			console.log 'Checked configuration'
			next err
		tasks.total = 5
		console.log 'Checking configuration'

		# Ensure
		@config.outPath or= @config.srcPath

		# Adjust Atomic Options
		if @config.srcPath is @config.outPath
			if @config.deleteBundledOutFiles
				console.log "Disabled deleteBundledOutFiles as your srcPath and outPath need to be different for that - as otherwise it would delete your source files!"
				@config.deleteBundledOutFiles = false
			if @config.compressOutFiles
				console.log "Disabled compressOutFiles as your srcPath and outPath need to be different for that - as otherwise it would overwrite your source files!"
				@config.compressOutFiles = false
		
		# Expand srcPath
		util.expandPath @config.srcPath, cwd, {}, (err,srcPath) =>
			return tasks.exit err if err
			@config.srcPath = srcPath
			tasks.complete err

		# Expand outPath
		util.expandPath @config.outPath, cwd, {}, (err,outPath) =>
			return tasks.exit err if err
			@config.outPath = outPath
			tasks.complete err

		# Expand bundleScriptPath
		if @config.bundleScriptPath
			util.expandPath @config.bundleScriptPath, cwd, {}, (err,bundleScriptPath) =>
				return tasks.exit err if err
				@config.bundleScriptPath = bundleScriptPath
				tasks.complete err
		else
			tasks.complete false
		
		# Expand bundleStylePath
		if @config.bundleStylePath
			util.expandPath @config.bundleStylePath, cwd, {}, (err,bundleStylePath) =>
				return tasks.exit err if err
				@config.bundleStylePath = bundleStylePath
				tasks.complete err
		else
			tasks.complete false

		# Expand srcLoaderPath
		if @config.srcLoaderPath
			util.expandPath @config.srcLoaderPath, cwd, {}, (err,srcLoaderPath) =>
				return tasks.exit err if err
				@config.srcLoaderPath = srcLoaderPath
				tasks.complete err
		else
			tasks.complete false

		# Auto find files?
		# Not yet implemented
		if @config.bundleScripts is true
			@config.bundleScripts = false
		if @config.bundleStyles is true
			@config.bundleStyles = false
		if @config.checkScripts is true
			@config.checkScripts = false

		# Completed
		true
	
	# Check files
	# next(err)
	checkFiles: (next) ->
		return next false  unless (@config.checkScripts||[]).length

		# Prepare
		console.log 'Checking files'

		# Cycle
		@forFilesIn(
			# Files
			@config.checkScripts

			# Directory
			@config.srcPath
			
			# Callback
			(fileFullPath,fileRelativePath,next) =>
				# Render
				@checkScriptFile(
					# File path
					fileFullPath

					# Next
					(err) =>
						next err
				)
			
			# Next
			(err) =>
				return next err	 if err
				console.log 'Checked files'
				next err
		)

		# Completed
		true

	# Copy srcPath to outPath
	# next(err)
	cpSrcToOut: (next) ->
		# Prepare
		return next false  if @config.outPath is @config.srcPath
		console.log 'Copying srcPath to outPath'

		# Remove outPath
		util.rmdir @config.outPath, (err) =>
			return next err	 if err

			# Copy srcPath to outPath
			util.cpdir @config.srcPath, @config.outPath, (err) ->
				# Next
				console.log 'Copied srcPath to outPath'
				next err
	
		# Completed
		true
	
	# Generate files
	# next(err)
	generateFiles: (next) ->
		# Prepare
		tasks = new util.Group (err) ->
			next err
		tasks.total += 3
		console.log 'Generating Files'

		# Generate src loader file
		@generateSrcLoaderFile (err) ->
			tasks.complete err

		# Generate bundled script file
		@generateBundledScriptFile (err) ->
			tasks.complete err

		# Generate bundle style file
		@generateBundledStyleFile (err) ->
			tasks.complete err

		# Completed
		true
	
	# Clean outPath
	# next(err)
	cleanOutPath: (next) ->
		# Check
		return next false  unless (@filesToClean||[]).length

		# Prepare
		tasks = new util.Group (err) =>
			console.log 'Cleaned outPath'
			next err
		tasks.total += @filesToClean.length
		console.log 'Cleaning outPath'
		
		# Delete files to clean
		for fileFullPath in @filesToClean
			fs.unlink fileFullPath, tasks.completer()

		# Completed
		true
	
	# Compress outPath
	# next(err)
	compressOutPath: (next) ->
		# Prepare
		return next false  unless @config.compressOutFiles
		console.log 'Compressing outPath'

		# Scan for files
		util.scandir(
			# Path
			@config.outPath

			# File Action
			# next(err)
			(fileFullPath,fileRelativePath,next) =>
				@compressFile fileFullPath, (err) ->
					next err
			
			# Dir Action
			false

			# Next
			(err) -> 
				console.log 'Compressed outPath'
				return next err
		)

		# Completed
		true


	# =====================================
	# Helpers

	# For each file in
	# callback(fileFullPath,fileRelativePath,next)
	# next(err)
	forFilesIn: (files,parentPath,callback,next) ->
		# Check
		return next false  unless (files||[]).length

		# Prepare
		tasks = new util.Group (err) =>
			next err
		tasks.total += files.length

		# Cycle
		for fileRelativePath in files
			# Expand filePath
			((fileRelativePath)=>
				util.expandPath fileRelativePath, parentPath, {}, (err,fileFullPath) =>
					return tasks.exit err if err

					# Callback
					callback fileFullPath, fileRelativePath, tasks.completer()
			)(fileRelativePath)
		
		# Completed
		true


	# =====================================
	# Loaders

	# Generate src loader file
	# next(err)
	generateSrcLoaderFile: (next) ->
		# Check
		return next false  unless @config.srcLoaderPath

		# Prepare
		templates = {}
		srcLoaderData = ''
		srcLoaderPath = @config.srcLoaderPath
		loadedInTemplates = null

		# Loaded in Templates
		templateTasks = new util.Group (err) =>
			# Check
			next err if err

			# Stringify scripts
			srcLoaderData += "scripts = [\n"
			for script in @config.bundleScripts
				srcLoaderData += "\t'#{script}'\n"
			srcLoaderData += "\]\n\n"

			# Stringify styles
			srcLoaderData += "styles = [\n"
			for style in @config.bundleStyles
				srcLoaderData += "\t'#{style}'\n"
			srcLoaderData += "\]\n\n"

			# Append Templates
			srcLoaderData += templates.srcLoader+"\n\n"+templates.srcLoaderHeader

			# Write in coffee first for debugging
			fs.writeFile srcLoaderPath, srcLoaderData, (err) ->
				# Check
				next err if err

				# Compile Script
				srcLoaderData = coffee.compile(srcLoaderData)

				# Now write in javascript
				fs.writeFile srcLoaderPath, srcLoaderData, (err) ->
					# Check
					next err if err

					# Good
					next false

		# Total Template Tasks
		templateTasks.total = if @config.srcLoaderHeader then 1 else 2

		# Load srcLoader Template
		fs.readFile __dirname+'/templates/srcLoader.coffee', (err,data) ->
			return templateTasks.exit err if err
			templates.srcLoader = data.toString()
			templateTasks.complete err

		# Load srcLoaderHeader Template
		if @config.srcLoaderHeader
			templates.srcLoaderHeader = @config.srcLoaderHeader
		else
			fs.readFile __dirname+'/templates/srcLoaderHeader.coffee', (err,data) ->
				return templateTasks.exit err if err
				templates.srcLoaderHeader = data.toString()
				templateTasks.complete err

		# Completed
		true


	# =====================================
	# Bundlers

	# ---------------------------------
	# Styles

	# Generate out style file
	# next(err)
	generateBundledStyleFile: (next) ->
		# Check
		return next false  unless @config.bundleStylePath

		# Prepare
		source = ''
		cleanFiles = []

		# Cycle
		@forFilesIn(
			# Files
			@config.bundleStyles

			# Directory
			@config.outPath
			
			# Callback
			(fileFullPath,fileRelativePath,next) =>
				# Ensure .less file exists
				extension = path.extname(fileRelativePath)
				if extension isnt '.less'
					# Determine less path
					_fileRelativePath = fileRelativePath
					_fileFullPath = fileFullPath
					fileRelativePath = _fileRelativePath.substring(0,_fileRelativePath.length-extension.length)+'.less'
					fileFullPath = _fileFullPath.substring(0,_fileFullPath.length-extension.length)+'.less'

					# Amend clean files
					if @config.deleteBundledOutFiles
						@filesToClean.push _fileFullPath
					@filesToClean.push fileFullPath

					# Check if less path exists
					path.exists fileFullPath, (exists) ->
						# It does
						if exists
							# Append source
							source += """@import "#{fileRelativePath}";\n"""
							next false
						# It doesn't
						else
							util.cp _fileFullPath, fileFullPath, (err) ->
								return next err	 if err
								# Append source
								source += """@import "#{fileRelativePath}";\n"""
								next false
				else
					# Amend clean files
					if @config.deleteBundledOutFiles
						@filesToClean.push fileFullPath

					# Append source
					source += """@import "#{fileRelativePath}";\n"""
					next false

			# Next
			(err) =>
				return next err 	if err

				# Compile file
				compileScriptData(
					# File Path
					@config.bundleStylePath

					# Source
					source

					# Next
					(err,result) =>
						return next err	 if err
						
						# Write
						fs.writeFile @config.bundleStylePath, result, (err) ->
							# Forward
							next err, result
				)
		)

		# Completed
		true

	# ---------------------------------
	# Scripts

	# Generate out script file
	# next(err)
	generateBundledScriptFile: (next) ->
		# Check
		return next false  unless @config.bundleScriptPath

		# Prepare
		results = {}

		# Cycle
		@forFilesIn(
			# Files
			@config.bundleScripts

			# Directory
			@config.outPath
			
			# Callback
			(fileFullPath,fileRelativePath,next) =>
				# Render
				@compileScriptFile(
					# File path
					fileFullPath

					# Next
					(err,result) =>
						return next err	 if err
						results[file] = result
						if @config.deleteBundledOutFiles
							@filesToClean.push fileFullPath
						next err
					
					# Write file
					false
				)
			
			# Next
			(err) =>
				return next err	 if err

				# Prepare
				result = ''

				# Cycle
				for file in @config.bundleScripts
					unless results[file]?
						return next new Error('A file failed to compile')
					result += results[file]

				# Write file
				fs.writeFile @config.bundleScriptPath, result, (err) ->
					next err
		)

		# Completed
		true


	# =====================================
	# Files

	# Compile the file
	# next(err)
	compileFile: (fileFullPath,next) ->
		# Prepare
		extension = path.extname fileFullPath

		# Handle
		switch extension
			when '.coffee'
				@compileScriptFile fileFullPath, next
			when '.less'
				@compileStyleFile fileFullPath, next
			when '.gif','.jpg','.jpeg','.png','.tiff','.bmp'
				@compressImageFile fileFullPath, next
			else
				false
		
		# Completed
		true
	
	# Compress the file
	# next(err)
	compressFile: (fileFullPath,next) ->
		# Prepare
		extension = path.extname fileFullPath

		# Handle
		switch extension
			when '.js'
				@compressScriptFile fileFullPath, next
			when '.css'
				@compressStyleFile fileFullPath, next
			when '.gif','.jpg','.jpeg','.png','.tiff','.bmp'
				@compressImageFile fileFullPath, next
			else
				false
		
		# Completed
		true
	

	# =====================================
	# Image Files

	# ---------------------------------
	# Compress

	# Compress Image File
	# next(err)
	compressImageFile: (fileFullPath,next) ->
		try
			pulverizr.compress fileFullPath, quiet: true
		catch err
			next err


	# =====================================
	# Style Files

	# ---------------------------------
	# Compile

	# Compile Style File
	# next(err,result)
	compileStyleData: (fileFullPath,src,next) ->
		# Prepare
		result = ''
		options =
			paths: [path.dirname(fileFullPath)]
			optimization: 1
			filename: fileFullPath

		# Compile
		new (less.Parser)(options).parse src, (err, tree) ->
			if err
				console.log err
				next new Error('Less compilation failed'), result
			else
				try
					# Compile
					result = tree.toCSS compress: 0

					# Write
					next false, result
				catch err
					next err, result

		# Completed
		true
	
	# Compile Style File
	# next(err,result)
	compileStyleFile: (fileFullPath,next,write=true) ->
		# Read
		fs.readFile fileFullPath, (err,data) =>
			return next err	 if err

			# Compile
			@compileStyleData fileFullPath, data.toString(), (err,result) ->
				return next err, result  if err or !write

				# Write
				fs.writeFile fileFullPath, result, (err) ->
					return next err	 if err

					# Forward
					next err, result
	
		# Completed
		true
	

	# =====================================
	# Script Files

	# ---------------------------------
	# Compile

	# Compile Script Data
	# next(err,result)
	compileScriptData: (extension,src,next) ->
		# Prepare
		result = ''

		# Compile
		try
			switch extension
				when '.coffee'
					result = coffee.compile src
				when '.js'
					result = src
				else
					throw new Error('Unknown script type')
		catch err
			next err
		
		# Forward
		next false, result

	# Compile Script File
	# next(err,result)
	compileScriptFile: (fileFullPath,next,write=true) ->
		# Read
		fs.readFile fileFullPath, (err,data) =>
			return next err	 if err

			# Compile
			@compileScriptData path.extname(fileFullPath), data.toString(), (err,result) ->
				return next err, result  if err or !write

				# Write
				fs.writeFile fileFullPath, result, (err) ->
					return next err	 if err

					# Forward
					next err, result
	
		# Completed
		true
	
	# ---------------------------------
	# Compress

	# Compress Script Data
	# next(err,result)
	compressScriptData: (src,next) ->
		# Compress
		ast = jsp.parse(src) # parse code and get the initial AST
		ast = pro.ast_mangle(ast) # get a new AST with mangled names
		ast = pro.ast_squeeze(ast) # get an AST with compression optimizations
		out = pro.gen_code(ast) # compressed code here

		# Forward
		return next false, out
	
	# Compress Script File
	# next(err,result)
	compressScriptFile: (fileFullPath,next,write=true) ->
		# Read
		fs.readFile fileFullPath, (err,data) =>
			return next err	 if err

			# Compile
			@compressScriptData data.toString(), (err,result) ->
				return next err, result  if err or !write

				# Write
				fs.writeFile fileFullPath, result, (err) ->
					return next err	 if err

					# Forward
					next err, result

		# Completed
		true
	
	# ---------------------------------
	# Check

	# Check Script Data
	# next(err,errord)
	checkScriptData: (src,next) ->
		# Prepare
		errord = false

		# Peform checks
		jshint src, @config.jshintOptions||{}
		result = jshint.data()
		result.errors or= []

		# Check for errors
		unless result.errors.length
			return next false, false
		
		# Log the errors
		for error in result.errors
			continue	unless error and error.raw

			# Errord
			errord = true

			# Log
			message = error.raw.replace(/\.$/,'').replace /\{([a-z])\}/, (a,b) ->
				error[b] or a
			evidence =
				if error.evidence
					"\n\t\t" + error.evidence.replace(/^\s+/, '')
				else
					''
			console.log "\tLine #{error.line}: #{message} #{evidence}"
		
		# Forward
		next false, errord
	

	# Check Script File
	# next(err,errord)
	checkScriptFile: (fileFullPath,next) ->
		# Log
		console.log 'Checking', fileFullPath

		# Read
		fs.readFile fileFullPath, (err,data) =>
			# Error
			return next err, false  if err

			# Check
			@checkScriptData data.toString(), (err,errord) ->
				# Forward
				return next err, errord

		# Completed
		true


# =====================================
# Export

module.exports =
	createInstance: (options) ->
		return new Buildr(options)
