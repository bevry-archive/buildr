# Welcome to Buildr

The (Java|Coffee)Script and (CSS|Less) (Builder|Bundler|Packer|Minifier|Merger|Checker)


## Install

1. [Install Node.js](https://github.com/balupton/node/wiki/Installing-Node.js)

1. Install [CoffeeScript](http://jashkenas.github.com/coffee-script/)
		
		npm -g install coffeescript

1. If you also want image compression, do this:

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

Before you use Buildr, you must specify some configuration for it. Here is an example:

``` coffeescript
 {
 	srcPath: 'src'
 	outPath: 'out'
	compress: true
	srcLoaderPath: 'src/loader.js'
	outStylePath: 'out/styles.css'
	outScriptPath: 'out/scripts.js'
 	scripts: [
 		'scripts/file1.js'
 		'scripts/file2.coffee'
 	]
 	styles: [
 		'styles/file1.css'
 		'styles/file2.less'
 	]
 }
```

Which works great for the following app structure:

> - app
	- src
		- scripts
			- file1.js
			- file2.coffee
		- styles
			- file1.css
			- file2.less

Using that configuration with buildr will:

1. Copy `app/src` to `app/out`
1. Generate `src/loader.js` which loads in the original styles and scripts into your page; use this file for development
1. Generates `out/styles.css` and `out/scripts.js` which are all your styles and scripts compressed and bundled together respectively; use these files for production

If you'd prefer to have the `srcPath` and the `outPath` the same, you can do that too.


## Run

### As a Command Line Tool

_Note: this option is currently disabled due to [this bug](https://github.com/balupton/buildr.npm/issues/8)_

1. Install Buildr Globally

		npm -g install buildr

2. Stick your configuration in `app/buildr.cson`

3. Within your app root, run `buildr`


### As a Module

1. Install Buildr Locally

		npm install buildr

2. Code

	``` coffeescript
	buildr = require 'buildr'
	config = {} # your configuration
	myBuildr = buildr.createInstance(config)
	myBuildr.process (err) ->
		throw err if err
		console.log 'Building completed'
	```


## License

Licensed under the [MIT License](http://creativecommons.org/licenses/MIT/)
Copyright 2011 [Benjamin Arthur Lupton](http://balupton.com)


## History

### Stability

- [Current Stable Release: 0.2](https://github.com/balupton/buildr.npm/tree/0.2)
- [Current Beta Release: 0.5](https://github.com/balupton/buildr.npm/tree/0.5)

To install a specific version, say version 0.2, run `npm install buildr@0.2`

### Changelog

- v0.5 July 9, 2011
	- Added srcLoader compilation

- v0.4 July 1, 2011
	- Extremely Simplified

- v0.3 May 31, 2011
	- Exploration into better architectures

- v0.2 April 2, 2011
	- Initial Release

- v0.1 March 23, 2011
	- Initial Commit

### Todo

- Needs javascript compression re-added
- Needs image compression re-added
- Needs auto file finding
- Needs jshint checking on `.js` files (not `.coffee` files)
- Needs no-config version
- Needs unit tests for the first time