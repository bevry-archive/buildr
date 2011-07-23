# Requires
fs = require 'fs'
path = require 'path'
util = require 'bal-util'
coffee = require 'coffee-script'
less = require 'less-bal'
pulverizr = require 'pulverizr-bal'
csslint = require('csslint').CSSLint
jshint = require('jshint').JSHINT
uglify = require 'uglify-js'
jsp = uglify.parser
pro = uglify.uglify
cwd = process.cwd()



# =====================================
# Prototypes

# Checks if an array contains a value
Array::has or= (value2) ->
	for value1 in @
		if value1 is value2
			return true
	return false


# =====================================
# Buildr

# Define
class Buildr

	# Configuration
	config: {
		# Paths
		srcPath: false # String
		outPath: false # String or false

		# Checking
		checkScripts: true # Array or true or false
		checkStyles: true # Array or true or false
		jshintOptions: false # Object or false
		csslintOptions: false # Object or false
		
		# Compression (requires outPath)
		compressScripts: true # Array or true or false
		compressStyles: true # Array or true or false
		compressImages: true # Array or true or false

		# Order
		scriptsOrder: false # Array or false
		stylesOrder: false # Array or false

		# Bundling (requires outPath and Order)
		bundleScriptPath: false # String or false
		bundleStylePath: false # String or false
		deleteBundledFiles: true # true or false

		# Loaders (requires Order)
		srcLoaderHeader: false # String or false
		srcLoaderPath: false # String or false
	}

	# Files to clean
	filesToClean: []

	# Error
	errors: []

	# Constructor
	constructor: (config) ->
		# Prepare
		config or= {}

		# Apply
		for own key, value of config
			@config[key] = value
		
		# Completed
		true


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
							@compressFiles (err) =>
								next err
	

	# ---------------------------------
	# Check Configuration

	# Check Configuration
	# next(err)
	checkConfiguration: (next) ->
		# Check
		return next new Error('srcPath is required')  unless @config.srcPath

		# Prepare
		tasks = new util.Group (err) ->
			console.log 'Checked configuration'
			next err
		tasks.total = 6
		console.log 'Checking configuration'

		# Ensure
		@config.outPath or= @config.srcPath

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

		# Adjust Atomic Options
		if @config.srcPath is @config.outPath
			@config.deleteBundledFiles = false
			if @config.compressScripts
				@config.compressScripts =
					if @config.bundleScriptPath
						[@config.bundleScriptPath]
					else
						false
			if @config.compressStyles
				@config.compressStyles =
					if @config.bundleStylePath
						[@config.bundleStylePath]
					else
						false
			if @config.compressImages
				@config.compressImages = false
		
		# Auto find files?
		# Not yet implemented
		if @config.bundleScripts is true
			@config.bundleScripts = false
		if @config.bundleStyles is true
			@config.bundleStyles = false
		
		# Finish
		tasks.complete false
	

	# ---------------------------------
	# Check Files

	# Check files
	# next(err)
	checkFiles: (next,config) ->
		# Prepare
		config or= @config
		return next false  unless config.checkScripts or config.checkStyles
		console.log 'Check files'

		# Handle
		@forFilesInDirectory(
			# Directory
			config.srcPath
			
			# Callback
			(fileFullPath,fileRelativePath,next) =>
				# Render
				@checkFile fileFullPath, next
			
			# Next
			(err) =>
				return next err	 if err
				console.log 'Checked files'
				next err
		)

		# Completed
		true
	

	# ---------------------------------
	# Copy srcPath to outPath

	# Copy srcPath to outPath
	# next(err)
	cpSrcToOut: (next,config) ->
		# Prepare
		config or= @config
		return next false  if config.outPath is config.srcPath
		console.log "Copying #{config.srcPath} to #{config.outPath}"

		# Remove outPath
		util.rmdir config.outPath, (err) =>
			return next err	 if err

			# Copy srcPath to outPath
			util.cpdir config.srcPath, config.outPath, (err) ->
				# Next
				console.log "Copied #{config.srcPath} to #{config.outPath}"
				next err
	
		# Completed
		true
	

	# ---------------------------------
	# Generate Files

	# Generate files
	# next(err)
	generateFiles: (next) ->
		# Prepare
		tasks = new util.Group (err) ->
			console.log 'Generated files'
			next err
		tasks.total += 3
		console.log 'Generating files'

		# Generate src loader file
		@generateSrcLoaderFile tasks.completer()

		# Generate bundled script file
		@generateBundledScriptFile tasks.completer()

		# Generate bundle style file
		@generateBundledStyleFile tasks.completer()

		# Completed
		true
	
	# Generate src loader file
	# next(err)
	generateSrcLoaderFile: (next,config) ->
		# Check
		config or= @config
		return next false  unless config.srcLoaderPath

		# Log
		console.log "Generating #{config.srcLoaderPath}"

		# Prepare
		templates = {}
		srcLoaderData = ''
		srcLoaderPath = config.srcLoaderPath
		loadedInTemplates = null

		# Loaded in Templates
		templateTasks = new util.Group (err) =>
			# Check
			next err if err

			# Stringify scripts
			srcLoaderData += "scripts = [\n"
			for script in config.scriptsOrder
				srcLoaderData += "\t'#{script}'\n"
			srcLoaderData += "\]\n\n"

			# Stringify styles
			srcLoaderData += "styles = [\n"
			for style in config.stylesOrder
				srcLoaderData += "\t'#{style}'\n"
			srcLoaderData += "\]\n\n"

			# Append Templates
			srcLoaderData += templates.srcLoader+"\n\n"+templates.srcLoaderHeader

			# Write in coffee first for debugging
			fs.writeFile srcLoaderPath, srcLoaderData, (err) ->
				# Check
				return next err  if err

				# Compile Script
				srcLoaderData = coffee.compile(srcLoaderData)

				# Now write in javascript
				fs.writeFile srcLoaderPath, srcLoaderData, (err) ->
					# Check
					return next err  if err

					# Log
					console.log "Generated #{config.srcLoaderPath}"
					
					# Good
					next false

		# Total Template Tasks
		templateTasks.total = if config.srcLoaderHeader then 1 else 2

		# Load srcLoader Template
		fs.readFile __dirname+'/templates/srcLoader.coffee', (err,data) ->
			return templateTasks.exit err if err
			templates.srcLoader = data.toString()
			templateTasks.complete err

		# Load srcLoaderHeader Template
		if config.srcLoaderHeader
			templates.srcLoaderHeader = config.srcLoaderHeader
		else
			fs.readFile __dirname+'/templates/srcLoaderHeader.coffee', (err,data) ->
				return templateTasks.exit err  if err
				templates.srcLoaderHeader = data.toString()
				templateTasks.complete err

		# Completed
		true

	# Generate out style file
	# next(err)
	generateBundledStyleFile: (next,config) ->
		# Check
		config or= @config
		return next false  unless config.bundleStylePath

		# Log
		console.log "Generating #{config.bundleStylePath}"
		
		# Prepare
		source = ''

		# Cycle
		@useOrScan(
			# Files
			config.stylesOrder

			# Directory
			@config.outPath
			
			# Callback
			(fileFullPath,fileRelativePath,next) =>
				# Ensure .less file exists
				extension = path.extname(fileRelativePath)
				switch extension
					# CSS
					when '.css'
						# Determine less path
						_fileRelativePath = fileRelativePath
						_fileFullPath = fileFullPath
						fileRelativePath = _fileRelativePath.substring(0,_fileRelativePath.length-extension.length)+'.less'
						fileFullPath = _fileFullPath.substring(0,_fileFullPath.length-extension.length)+'.less'

						# Amend clean files
						if config.deleteBundledFiles
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
								# Create it
								util.cp _fileFullPath, fileFullPath, (err) ->
									return next err	 if err
									# Append source
									source += """@import "#{fileRelativePath}";\n"""
									next false
					
					# Less
					when '.less'
						# Amend clean files
						if config.deleteBundledFiles
							@filesToClean.push fileFullPath

						# Append source
						source += """@import "#{fileRelativePath}";\n"""
						next false
					
					# Something else
					else
						next false

			# Next
			(err) =>
				return next err 	if err

				# Compile file
				@compileStyleData(
					# File Path
					config.bundleStylePath

					# Source
					source

					# Next
					(err,result) =>
						return next err	 if err
						
						# Write
						fs.writeFile config.bundleStylePath, result, (err) ->
							# Log
							console.log "Generated #{config.bundleStylePath}"
							
							# Forward
							next err, result
				)
		)

		# Completed
		true

	# Generate out script file
	# next(err)
	generateBundledScriptFile: (next,config) ->
		# Check
		config or= @config
		return next false  unless config.bundleScriptPath

		# Log
		console.log "Generating #{config.bundleScriptPath}"
		
		# Prepare
		results = {}

		# Cycle
		@useOrScan(
			# Files
			config.scriptsOrder

			# Directory
			config.outPath
			
			# Callback
			(fileFullPath,fileRelativePath,next) =>
				# Ensure valid extension
				extension = path.extname(fileRelativePath)
				switch extension
					# Script
					when '.js','.coffee'
						# Render
						@compileScriptFile(
							# File path
							fileFullPath

							# Next
							(err,result) =>
								return next err	 if err
								results[fileRelativePath] = result
								if config.deleteBundledFiles
									@filesToClean.push fileFullPath
								next err
							
							# Write file
							false
						)
					
					# Else
					else
						next false
				
			# Next
			(err) =>
				return next err	 if err

				# Prepare
				result = ''

				# Cycle Array
				if config.scriptsOrder.has?
					for fileRelativePath in config.scriptsOrder
						return next new Error("The file #{fileRelativePath} failed to compile")  unless results[fileRelativePath]?
						result += results[fileRelativePath]

				# Write file
				fs.writeFile config.bundleScriptPath, result, (err) ->
					# Log
					console.log "Generated #{config.bundleScriptPath}"
					
					# Forward
					next err
		)

		# Completed
		true


	# ---------------------------------
	# Clean outPath

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
			console.log "Cleaning #{fileFullPath}"
			fs.unlink fileFullPath, tasks.completer()

		# Completed
		true
	

	# ---------------------------------
	# Compress Files

	# Compress files
	# next(err)
	compressFiles: (next,config) ->
		# Prepare
		config or= @config
		return next false  unless config.compressScripts or config.compressStyles or config.compressImages
		console.log 'Compress files'

		# Handle
		@forFilesInDirectory(
			# Directory
			config.outPath
			
			# Callback
			(fileFullPath,fileRelativePath,next) =>
				# Render
				@compressFile fileFullPath, next
			
			# Next
			(err) =>
				return next err	 if err
				console.log 'Compressed files'
				next err
		)

		# Completed
		true


	# =====================================
	# Helpers

	# For each file in an array
	# callback(fileFullPath,fileRelativePath,next)
	# next(err)
	forFilesInArray: (files,parentPath,callback,next) ->
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
					callback fileFullPath, fileRelativePath, tasks.completer()
			)(fileRelativePath)
		
		# Completed
		true
	
	# For each file in a directory
	# callback(fileFullPath,fileRelativePath,next)
	# next(err)
	forFilesInDirectory: (parentPath,callback,next) ->
		# Scan for files
		util.scandir(
			# Path
			parentPath

			# File Action
			# next(err)
			callback
			
			# Dir Action
			false

			# Next
			next
		)

		# Completed
		true
	
	# Use or scan
	# callback(fileFullPath,fileRelativePath,next)
	# next(err)
	useOrScan: (files,parentPath,callback,next) ->
		# Handle
		if files is true
			@forFilesInDir(
				# Files
				files

				# Directory
				parentPath

				# Callback
				callback

				# Next
				next
			)
		else if files and files.length
			@forFilesInArray(
				# Files
				files

				# Directory
				parentPath

				# Callback
				callback

				# Next
				next
			)
		else
			next false

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
			else
				next false
		
		# Completed
		true
	
	# Compress the file
	# next(err)
	compressFile: (fileFullPath,next,config) ->
		# Prepare
		config or= @config
		extension = path.extname fileFullPath

		# Handle
		switch extension
			# Scripts
			when '.js'
				if config.compressScripts is true or config.compressScripts.has? and config.compressScripts.has(fileFullPath)
					@compressScriptFile fileFullPath, next
				else
					next false
			
			# Styles
			when '.css'
				if config.compressStyles is true or config.compressStyles.has? and config.compressStyles.has(fileFullPath)
					@compressStyleFile fileFullPath, next
				else
					next false
			
			# Images
			when '.gif','.jpg','.jpeg','.png','.tiff','.bmp'
				if config.compressImages is true or config.compressImages.has? and config.compressImages.has(fileFullPath)
					@compressImageFile fileFullPath, next
				else
					next false
			
			# Other
			else
				next false
		
		# Completed
		true
	
	# Check the file
	# next(err)
	checkFile: (fileFullPath,next,config) ->
		# Prepare
		config or= @config
		extension = path.extname fileFullPath

		# Handle
		switch extension
			when '.js'
				if config.checkScripts is true or config.checkScripts.has? and config.checkScripts.has(fileFullPath)
					@checkScriptFile fileFullPath, next
				else
					next false
			when '.css'
				if config.checkStyles is true or config.checkStyles.has? and config.checkStyles.has(fileFullPath)
					@checkStyleFile fileFullPath, next
				else
					next false
			else
				next false
		
		# Completed
		true
	

	# =====================================
	# Image Files

	# ---------------------------------
	# Compress

	# Compress Image File
	# next(err)
	compressImageFile: (fileFullPath,next) ->
		# Log
		console.log "Compressing #{fileFullPath}"

		# Attempt
		try
			# Compress
			pulverizr.compress fileFullPath, quiet: true
			
			# Log
			console.log "Compressed #{fileFullPath}"

			# Forward
			next false
		
		# Error
		catch err
			# Forward
			next err
		
		# Complete
		true

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
		# Log
		# console.log "Compiling #{fileFullPath}"

		# Read
		fs.readFile fileFullPath, (err,data) =>
			return next err	 if err

			# Compile
			@compileStyleData fileFullPath, data.toString(), (err,result) ->
				return next err, result  if err or !write

				# Write
				fs.writeFile fileFullPath, result, (err) ->
					return next err	 if err

					# Log
					# console.log "Compiled #{fileFullPath}"
				
					# Forward
					next err, result
	
		# Completed
		true
	
	# ---------------------------------
	# Compress

	# Compress Style File
	# next(err,result)
	compressStyleData: (fileFullPath,src,next) ->
		# Prepare
		result = ''
		options =
			paths: [path.dirname(fileFullPath)]
			optimization: 1
			filename: fileFullPath

		# Compress
		new (less.Parser)(options).parse src, (err, tree) ->
			if err
				console.log err
				next new Error('Less compilation failed'), result
			else
				try
					# Compress
					result = tree.toCSS compress: 1

					# Write
					next false, result
				catch err
					next err, result

		# Completed
		true
	
	# Compress Style File
	# next(err,result)
	compressStyleFile: (fileFullPath,next,write=true) ->
		# Log
		console.log "Compressing #{fileFullPath}"

		# Read
		fs.readFile fileFullPath, (err,data) =>
			return next err	 if err

			# Compress
			@compressStyleData fileFullPath, data.toString(), (err,result) ->
				return next err, result  if err or !write

				# Write
				fs.writeFile fileFullPath, result, (err) ->
					return next err	 if err

					# Log
					console.log "Compressed #{fileFullPath}"
				
					# Forward
					next err, result
	
		# Completed
		true
	
	# ---------------------------------
	# Check

	# Check Style Data
	# next(err,errord)
	checkStyleData: (fileFullPath,src,next,config) ->
		# Prepare
		config or= @config
		errord = false

		# Peform checks
		result = csslint.verify src, config.csslintOptions||{}
		formatId = 'text'

		# Check for errors
		unless result.messages.length
			return next false, false
		
		# Log the errors
		for message in result.messages
			continue	unless message and message.type is 'error'

			# Errord
			errord = true

		# Output
		if errord
			console.log csslint.getFormatter(formatId).formatResults(result, fileFullPath, formatId)

		# Forward
		next false, errord
	

	# Check Style File
	# next(err,errord)
	checkStyleFile: (fileFullPath,next) ->
		# Log
		console.log "Checking #{fileFullPath}"

		# Read
		fs.readFile fileFullPath, (err,data) =>
			# Error
			return next err, false  if err

			# Check
			@checkStyleData fileFullPath, data.toString(), (err,errord) ->
				return next err	 if err
				
				# Log
				console.log "Checked #{fileFullPath}"

				# Forward
				return next err, errord

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
		result = false

		# Compile
		try
			switch extension
				when '.coffee'
					result = coffee.compile src
				when '.js'
					result = src
				else
					throw new Error('Unknown script type: '+extension)
		catch err
			next err
		
		# Forward
		next false, result

	# Compile Script File
	# next(err,result)
	compileScriptFile: (fileFullPath,next,write=true) ->
		# Log
		# console.log "Compiling #{fileFullPath}"

		# Read
		fs.readFile fileFullPath, (err,data) =>
			return next err	 if err

			# Compile
			@compileScriptData path.extname(fileFullPath), data.toString(), (err,result) ->
				return next err, result  if err or !write

				# Write
				fs.writeFile fileFullPath, result, (err) ->
					return next err	 if err

					# Log
					# console.log "Compiled #{fileFullPath}"

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
		# Log
		console.log "Compressing #{fileFullPath}"

		# Read
		fs.readFile fileFullPath, (err,data) =>
			return next err	 if err

			# Compile
			@compressScriptData data.toString(), (err,result) ->
				return next err, result  if err or !write

				# Write
				fs.writeFile fileFullPath, result, (err) ->
					return next err	 if err

					# Log
					console.log "Compressed #{fileFullPath}"
				
					# Forward
					next err, result

		# Completed
		true
	
	# ---------------------------------
	# Check

	# Check Script Data
	# next(err,errord)
	checkScriptData: (fileFullPath,src,next,config) ->
		# Prepare
		config or= @config
		errord = false

		# Peform checks
		jshint src, config.jshintOptions||{}
		result = jshint.data()
		result.errors or= []

		# Check for errors
		unless result.errors.length
			return next false, false
		
		# Log the file
		console.log "\n#{fileFullPath}:"

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
					"\n\t" + error.evidence.replace(/^\s+/, '')
				else
					''
			console.log "\tLine #{error.line}: #{message} #{evidence}\n"
		
		# Forward
		next false, errord
	

	# Check Script File
	# next(err,errord)
	checkScriptFile: (fileFullPath,next) ->
		# Log
		console.log "Checking #{fileFullPath}"

		# Read
		fs.readFile fileFullPath, (err,data) =>
			# Error
			return next err, false  if err

			# Check
			@checkScriptData fileFullPath, data.toString(), (err,errord) ->
				return next err	 if err

				# Log
				console.log "Checked #{fileFullPath}"

				# Forward
				return next err, errord

		# Completed
		true


# =====================================
# Export

module.exports =
	createInstance: (options) ->
		return new Buildr(options)
