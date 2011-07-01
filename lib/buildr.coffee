# Requires
fs = require 'fs'
path = require 'path'
util = require 'bal-util'
coffee = require 'coffee-script'
less = require 'less'
cwd = process.cwd()

# -------------------------------------
# Body

# Define Buildr
class Buildr
	
	# Configuration
	config: {}

	# Create
	constructor: (@config) ->

	# Process
	process: (next) ->
		# Prepare
		tasks = new util.Group (err) ->
			next err
		tasks.total += 2

		# Expand configuration paths
		@expandPaths (err) =>
			return next err if err
			
			# Copy srcPath to outPath
			@cpSrcToOut (err) =>
				return next err if err

				# Generate out script file
				@generateOutScriptFile (err) ->
					tasks.complete err

				# Generate out script file
				@generateOutStyleFile (err) ->
					tasks.complete err

	# -------------------------------------
	# Process Steps

	# Expand configuration paths
	# next(err)
	expandPaths: (next) ->
		# Prepare
		tasks = new util.Group (err) ->
			next err
		tasks.total += 3

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
		
		# Expand outScriptPath
		util.expandPath @config.outScriptPath, cwd, {}, (err,outScriptPath) =>
			return tasks.exit err if err
			@config.outScriptPath = outScriptPath
			tasks.complete err
		

	# Copy srcPath to outPath
	# next(err)
	cpSrcToOut: (next) ->
		# Check
		if @config.outPath is @config.srcPath
			return next false
		
		# Remove outPath
		util.rmdir @config.outPath, (err) =>
			return next err if err

			# Copy srcPath to outPath
			util.cpdir @config.srcPath, @config.outPath, (err) ->
				# Next
				next err
	
	# Generate out style file
	# next(err)
	generateOutStyleFile: (next) ->
		# Prepare
		outStylePath = @config.outStylePath
		outPath = @config.outPath
		options = 
			paths: [outPath]
			optimization: 1
			filename: outStylePath
		
		# Fetch Data
		@generateOutStyle (err,data) ->
			return next err if err
			
			# Compile
			new (less.Parser)(options).parse data, (err, tree) ->
				if err
					console.log err
					next new Error('Less compilation failed')
				else
					try
						css = tree.toCSS(compress: 1)
						fs.writeFile outStylePath, css, (err) ->
							next err
					catch err
						next err
	
	# Generate out script file
	# next(err)
	generateOutScriptFile: (next) ->
		# Prepare
		results = {}
		tasks = new util.Group (err) =>
			return next err if err

			# Prepare
			result = ''

			# Cycle
			for file in @config.scripts
				unless results[file]?
					return next new Error('A file failed to compile')
				result += results[file]
			
			# Write file
			fs.writeFile @config.outScriptPath, result, (err) ->
				next err
		tasks.total += @config.scripts.length
		
		# Cycle
		for file in @config.scripts
			# Expand filePath
			((file)=>
				util.expandPath file, @config.outPath, {}, (err,filePath) =>
					return tasks.exit err if err
					
					# Render
					@getScriptData filePath, (err,data) ->
						return tasks.exit err if err
						results[file] = data
						tasks.complete err
			)(file)

	# -------------------------------------
	# Utilities

	# next(err,source)
	generateOutStyle: (next) ->
		# Prepare
		source = ''
		tasks = new util.Group (err) =>
			next err, source
		tasks.total += @config.styles.length

		# Cycle
		for file in @config.styles
			# Expand filePath
			((file)=>
				util.expandPath file, @config.outPath, {}, (err,filePath) =>
					return tasks.exit err if err
					
					# Ensure less
					# Append source
					extension = path.extname(file)
					if extension isnt '.less'
						oldFile = file
						oldFilePath = filePath
						file = oldFile.substring(0,oldFile.length-extension.length)+'.less'
						filePath = oldFilePath.substring(0,oldFilePath.length-extension.length)+'.less'
						path.exists filePath, (exists) ->
							if exists
								source += """@import "#{file}";\n"""
								tasks.complete false
							else
								util.cp oldFilePath, filePath, (err) ->
									return tasks.exit err if err
									source += """@import "#{file}";\n"""
									tasks.complete false
					else
						source += """@import "#{file}";\n"""
						tasks.complete false
			)(file)
	
	# Compile
	# next(err,data)
	getScriptData: (filePath,next) ->
		# Read
		fs.readFile filePath, (err,data) ->
			return next err if err
			result = ''

			# Compile
			try
				switch path.extname(filePath)
					when '.coffee'
						result = coffee.compile(data.toString())
					when '.js'
						result = data.toString()
					else
						throw new Error('Unknown script type')
			catch err
				next err

			next false, result


# -------------------------------------
# Footer

# Export
module.exports =
	createInstance: (options) ->
		return new Buildr(options)