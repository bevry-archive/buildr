# Welcome to Buildr

The (Java|Coffee)Script and (CSS|Less) (Builder|Bundler|Packer|Minifier|Merger|Checker)


## Install

1. [Install Node.js](http://bevry.me/node/install)

1. Install dependencies for image compression

	- On OSX
		
			ruby -e "$(curl -fsSLk https://gist.github.com/raw/323731/install_homebrew.rb)"
			brew install gifsicle libjpeg optipng pngcrush
	
	- On Apt Linux
		
			sudo apt-get update && sudo apt-get install gifsicle libjpeg-progs optipng pngcrush
	
	- On Yum Linux
		
			sudo yum -y install gifsicle libjpeg-progs optipng pngcrush
	
	- Windows

		> Hahahahaha


## Configure

Before you use Buildr, you must specify some configuration for it. The available configuration is:

``` coffeescript
{
	# Options
	name: null # (name to be outputted in log messages) String or null
	log: true # (log status updates to console?) true or false
	watch: false # (automatically rebuild on file change?) true or false

	# Handlers
	buildHandler: false # (fired when build completed) function or false
	rebuildHandler: false # (fired when rebuild completed) function or false
	successHandler: false # (fired when (re)build completed successfully) function or false

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

	# Bundling (requires Order)
	bundleScriptPath: false # String or false
	bundleStylePath: false # String or false
	deleteBundledFiles: true # (requires outPath) true or false 

	# Loaders (requires Order)
	srcLoaderHeader: false # String or false
	srcLoaderPath: false # String or false
}
```

The above values are the default values for those options. The settings which are set to `true` will auto-detect the files for you.


### Options

There are currently two options available, the `log` and `watch` options.

- The `log` option when enabled will output all status messages, by default this is enabled.
- The `watch` option when enabled will allow buildr to run in the background watching for changes in our `srcPath`, if a change is detected then our project is automatically rebuilt for us, by default this is disabled.


### Handlers

There are two handlers you can configure, they are the `buildHandler` and the `rebuildHandler`.

- The `buildHandler` is fired after our project has been built.
- The `rebuildHandler` is fired after our project has been rebuilt. Our project is rebuilt when we utilise the `watch: true` config option, which scans for changes in the background and automatically rebuilds our project on change. If this isn't specified, then the `buildHandler` will automatically be used as the `rebuildHandler`.

They are both passed a single argument called `err` which is either an `Error` instance, or `false` if no error occurred. They both also have default values, so you don't need to specify them if you don't want to.


### Checking

To pass your scripts through jshint and your styles through csslint, you'd want the following configuration:

``` coffeescript
{
	# Paths
	srcPath: 'src' # String

	# Checking
	checkScripts: true # Array or true or false
	checkStyles: true # Array or true or false
	jshintOptions: false # Object or false
	csslintOptions: false # Object or false
}
```


### Compression

To copy your `src` directory to an `out` directory, then compile and compress all your styles and scripts in the `out` directory, you'd want the following configuration:

``` coffeescript
{
	# Paths
	srcPath: 'src' # String
	outPath: 'out' # String or false

	# Compression (without outPath only the generated bundle files are compressed)
	compressScripts: true # Array or true or false
	compressStyles: true # Array or true or false
	compressImages: true # Array or true or false
}
```

If your `outPath` is the same as your `srcPath` then the only files which will be compressed are the generated bundle files.


### Bundling

To bundle all your style files into one file called `out/bundled.css` and all your script files into one file called `out/bundled.js`, you'd want the following configuration:

``` coffeescript
{
	# Paths
	srcPath: 'src' # String
	outPath: 'out' # String or false

	# Order
	scriptsOrder: [
		'script1.js'
		'script2.coffee'
	] # Array or false
	stylesOrder: [
		'style1.css'
		'style2.less'
	] # Array or false

	# Bundling (requires Order)
	bundleScriptPath: false # String or false
	bundleStylePath: false # String or false
	deleteBundledFiles: true # (requires outPath) true or false 
}
```


### Loaders

To generate a source loader file called `src/loader.js` which will load in all your source styles and scripts into the page, you can use the following:

``` coffeescript
{
	# Paths
	srcPath: 'src' # String

	# Order
	scriptsOrder: [
		'script1.js'
		'script2.coffee'
	] # Array or false
	stylesOrder: [
		'style1.css'
		'style2.less'
	] # Array or false

	# Loaders (requires Order)
	srcLoaderHeader: '''
		# Prepare
		myprojectEl = document.getElementById('myproject-include')
		myprojectBaseUrl = myprojectEl.src.replace(/\\?.*$/,'').replace(/loader\\.js$/, '').replace(/\\/+$/, '')+'/'

		# Load in with Buildr
		myprojectBuildr = new window.Buildr {
			baseUrl: myprojectBaseUrl
			beforeEl: myprojectEl
			serverCompilation: window.serverCompilation or false
			scripts: scripts
			styles: styles
		}
		myprojectBuildr.load()
		''' # note, all \ in this are escaped due to it being in a string
	srcLoaderPath: 'src/myproject.loader.js' # String or false
}
```

Then include into your page with the following html:

``` html
<script id="myproject-include" src="../../loader.js"></script>
```

This is incredibly useful for developing apps which have lots of files, as instead of updating all your demo page's html with the new script and style files all the time, you just include the loader.


### Combining

You can feel free to combine any of the configurations above to get something which checks, compiles, compresses, bundles, and generates loaders too. Though compression and bundling is dependent on having an `outPath` which is different from your `srcPath`.


## Run

### As a Command Line Tool

Within your application folder

1. Install Buildr Globally

		npm -g install buildr

2. Stick your configuration in `buildr.cson`

3. Run the global buildr

		buildr

You may specify the filename for configuring by passing -f <filename> or --file <filename> on the command-line.

### As a Module

Within your application folder

1. Install Buildr Locally

		npm install buildr

2. Code `buildr.coffee`

	``` coffeescript
	buildr = require 'buildr'
	config = {} # your configuration
	myBuildr = buildr.createInstance(config)
	myBuildr.process (err) ->
		throw err if err
		console.log 'Building completed'
	```

3. Run your buildr file

		coffee buildr.coffee


## License

Licensed under the [MIT License](http://creativecommons.org/licenses/MIT/)
Copyright 2011 [Benjamin Arthur Lupton](http://balupton.com)


## History

### Changelog

- v0.8.7 March 24, 2013
  - Fix issue 34
  - Fix syntax error in CLI script which prevents error reporting.
  - Copy source files recursively again (reverting v0.8.5 fix) which is safe because we switched to rimraf (to fix issue 34).

- v0.8.6 March 17, 2013
  - Replace deprecated path.exists call with fs.exists.
  - Fix build issue with Cakefile.
  - Fix issue 32 and 33

- v0.8.5 November 11, 2012
  - Fix problem with copying of hidden directories like .svn/

- v0.8.4 November 5, 2012
  - Fix bug 31: Log level debug is always used, regardless of configuration.

- v0.8.3 October 28, 2012
  - Feature request #13: specify .cson file at command line
  - Feature request #15: Macro preprocessor
  - Fix bugs 8, 19, 20, 21, 23, 25, 27, 28, 30
  - Use cake to build JavaScript, making buildr easier to run
  - Updated dependencies to fix several bugs

- v0.8 September 27, 2011
	- Fixed concurrency support
	- Fixed compression under certain configurations
	- Added [Caterpillar](https://github.com/balupton/caterpillar.npm) for awesome console logging

- v0.7 August 22, 2011
	- Added `watch`, `buildHandler` and `rebuildHandler` options

- v0.6 July 21, 2011
	- v0.6.0 July 21, 2011
		- Added javascript, image and css compression
		- Added jshint and csslint checks
	- v0.6.6 August 16, 2011
		- Fixed relative paths between outPath and bundledPaths

- v0.5 July 9, 2011
	- Added srcLoader compilation

- v0.4 July 1, 2011
	- Extremely Simplified
	- Only supports bundling of js|coffee and css|less files currently

- v0.3 May 31, 2011
	- Exploration into better architectures

- v0.2 April 2, 2011
	- Initial Release

- v0.1 March 23, 2011
	- Initial Commit

### Todo

- Needs auto file finding for bundling/orders
- Needs no-config version
- Needs unit tests
