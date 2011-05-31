# Require
jshint = null

# Configure
config =
	
	# Common
	common:
		css:
			files:
				'dep/ext-3.2.1/resources/css/ext-all-notheme.css'
				'dep/ext-3.2.1/resources/css/xtheme-gray.css'
				'css/aloha.css'
		js:
			files:
				'util/base.js'

				'dep/ext-3.2.1/adapter/jquery/ext-jquery-adapter.js'
				'dep/ext-3.2.1/ext-all.js'

				'dep/jquery.json-2.2.min.js'
				'dep/jquery.getUrlParam.js'
				'dep/jquery.store.js'

				'core/jquery.aloha.js'
				'util/lang.js'
				'util/range.js'
				'util/position.js'
				'util/dom.js'
				'core/ext-alohaproxy.js'
				'core/ext-alohareader.js'
				'core/ext-alohatreeloader.js'
				'core/core.js'
				'core/ui.js'
				'core/ui-attributefield.js'
				'core/ui-browser.js'
				'core/editable.js'
				'core/floatingmenu.js'
				'core/ierange-m2.js'
				'core/log.js'
				'core/markup.js'
				'core/message.js'
				'core/plugin.js'
				'core/selection.js'
				'core/sidebar.js'
				'core/repositorymanager.js'
				'core/repository.js'
				'core/repositoryobjects.js'

	# Check files
	check:
		css:
			files: 'common'
			option:
		js:
			files: 'common'
			options:
	
	# Copies src to out
	dirs:
		out: './out'
		src: './src'
		cp: true
	
	# Pack files
	pack:
		css:
			dir: './src'
			out: 'aloha.css'
			files: 'common'
		js:
			dir: './src'
			out: 'aloha.js'
			files: 'common'

	# Merge files
	merge:
		css:
			dir: './out'
			out: 'aloha.css'
			files: 'common'
			del: true
		js:
			dir: './out'
			out: 'aloha.js'
			files: 'common'
			del: true
	
	# Compress files
	compress:
		css:
			dir: './out'
		js:
			dir: './out'
		img:
			dir: './out'


# Common
Common =
	isIgnored: ->
	expandPath: ->


# Buildr
class Buildr
	types: ['js','css']

	task: (args={}, callback) ->
		# Prepare
		args.common or= {}

		# Check
		unless args.task?
			throw new Error 'Buildr.task requires args.task to be set'

		# Forward
		for type in @types
			# Inform
			typeArgs = args[type] or {}
			for own key, value of common
				unless typeArgs[key] then typeArgs[key] = value
			
			# Call
			component = @[type]
			component[args.task].apply(component,typeArgs)

	check: (args..., callback) ->
		args.task = 'check'
		@task(args, callback)
	

	bundle: (args..., callback) ->
		args.task = 'bundle'
		@task(args, callback)
	
	compress: (args..., callback) ->
		args.task = 'compress'
		@task(args, callback)


	# JavaScript Buildr Component
	js: 
		
		# Run javascript through JSLint and reports back any code quality problems
		check: (args={}, callback) ->
			# Prepare
			args.files or= {}

			# Load JSHint
			jshint or= require('jshint').JSHINT

			# Log
			console.log "\nChecking JS Files:"
			
			# Check files
			args.files.forEach (filePath) ->
				# Ignore?
				if !filePath or Common.isIgnored(args.ignore.files, filePath)
					return
				
				# Prepare
				fileSrcPath = Common.expandPath(
					filePath, config.rootPath, config.directories.src
				)
				fileData = fs.readFileSync(fileSrcPath).toString()
				foundError = false
				result = false
				
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
		

# Dance
async.parallel [

	# Check src js files for problems
	(next) -> Buildr.js.check(
		# Options
		{
			files: config.files.js
			dir: config.dir.src
		}

		# Completed
		->
			# Log
			console.log 'Completed checking src js files for problems'

			# Dance
			async.parallel [
				# Bundle src js files
				(next) -> Buildr.js.bundle(
						# Options
						{
							files: config.files.js
							dir: config.dir.src
							out: config.dir.src+config.bundle.js
							mode: 'indi' # individual files references
							del: false
						}

						# Completed
						->
							# Log
							console.log 'Completed bundling src js files'

							# Forward
							next()
				
				# Bundle out js files
				(next) -> Buildr.js.bundle(
					# Options
					{
						files: config.files.js
						dir: config.dir.src
						out: config.dir.src+config.bundle.js
						mode: 'pack' # all files packed into one
						del: true
					}
					
					# Completed
					->
						# Log
						console.log 'Completed bundling out js files'

						# Compress out js files
						Buildr.js.compress(
							# Options
							{
								dir: config.dir.out
							}

							# Complete
							->
								# Log
								console.log 'Completed compressing out js files'

								# Forward
								next()
						)
			
			],
			->
				# Log
				console.log 'Completed bundling js files'
	
	# Check src css files for problems
	(next) -> Buildr.css.check(
		# Options
		{
			
		}
	)	