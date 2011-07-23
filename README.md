# Welcome to Buildr

The (Java|Coffee)Script and (CSS|Less) (Builder|Bundler|Packer|Minifier|Merger|Checker)


## Install

1. [Install Node.js](https://github.com/balupton/node/wiki/Installing-Node.js)

1. Install [CoffeeScript](http://jashkenas.github.com/coffee-script/)
		
		npm -g install coffeescript

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
```

The above values are the default values for those options. The settings which are set to `true` will autodect the files for you.


### Checking

To pass your scripts through jshint, and your styles through csslint, you'd want the following configuration:

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

	# Compression (requires outPath)
	compressScripts: true # Array or true or false
	compressStyles: true # Array or true or false
	compressImages: true # Array or true or false
}
```


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

	# Bundling (requires outPath and Order)
	bundleScriptPath: false # String or false
	bundleStylePath: false # String or false
	deleteBundledFiles: true # true or false
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

_Note: this option is currently disabled due to [this bug](https://github.com/balupton/buildr.npm/issues/8)_

Within your application folder

1. Install Buildr Globally

		npm -g install buildr

2. Stick your configuration in `buildr.cson`

3. Run the global buildr

		buildr


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

- v0.6 July 21, 2011
	- Added javascript, image and css compression
	- Added jshint and csslint checks

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
