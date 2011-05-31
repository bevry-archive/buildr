# Welcome to Buildr. The JavaScript Project Checker, Bundler, & Compressor.


## Installation

1. [Install Node.js](https://github.com/balupton/node/wiki/Installing-Node.js)

1. Install CoffeeScript
		
		npm -g install coffeescript

1. Install Buildr

		npm -g install buildr

1. Optional. If you would also like to support image compression

	- On OSX
		
			npm -g install pulverizr-bal
			ruby -e "$(curl -fsSLk https://gist.github.com/raw/323731/install_homebrew.rb)"
			brew install gifsicle libjpeg optipng pngcrush
	
	- On Apt Linux
		
			npm -g install pulverizr-bal
			sudo apt-get update && sudo apt-get install gifsicle libjpeg-progs optipng pngcrush
	
	- On Yum Linux
		
			npm -g install pulverizr-bal
			sudo yum -y install gifsicle libjpeg-progs optipng pngcrush

	- On Windows

		You're out of luck


## Usage

In the javascript program which you would like to buldr, run the following in terminal:

	buildr .


## Configuration

Buildr does not require any configuration by default, but if you would like to configure it you can create a `package.json` file which can look something like this:

``` javascript
 {
    "name": "my-project",
    "buildr": {
        "compress": true,
        "bundle": true,
        "directories": {
            "out": "./out",
            "src": "./src"
        },
        "files": true
 }
```


If you would like configure it even further, the following options are available under the `buildr` key:

- `compress`: a boolean value or an object, if an object:
	- `js`: a boolean value
	- `css`: a boolean value
	- `img`: a boolean value
	- `html`: a boolean value

- `check`: a boolean value or an object, if an object:
	- `js`: a boolean value; whether or not we should run javascript through the JSLint checker before building
	- `jsOptions`: an object; to pass to the JSLint checker

- `bundle`: a boolean value or an object, if an object:
	- `js`: a boolean value or a javascript filename; what should the bundled Javascript file be called?
	- `css`: a boolean value or a css filename; what should hte bundled CSS file be called?
	- `src`: a boolean value; whether or not we should bundle the source files too

- `directories`: an object
	- `out`: a directory path; of where the compiled files will go
	- `src`: a directory path; of where source files come from

- `subpackages`: an array; containing the locations of each subpackage to compress and bundle

- `files`: an object
	- `js`: a boolean value or array; of javascript files to compress and bundle
	- `css`: a boolean value or array; of css files to compress and bundle
	- `img`: a boolean value or array; of image files to compress and bundle

- `templates`: an object
	- `out_bundle_header.js`: a file path; to the header for the out bundled file
	- `out_bundle_footer.js`: a file path; to the footer for the out bundled file
	- `out_bundle_item.js`: a file path; to the replace string for each out bundled file
	- `out_bundle_subpackage.js`: a file path; to the replace string for each out bundled subpackage
	- `src_bundle_header.js`: a file path; to the header for the src bundled file
	- `src_bundle_footer.js`: a file path; to the footer for the src bundled file
	- `src_bundle_item.js`: a file path; to the replace string for each src bundled file
	- `src_bundle_subpackage.js`: a file path; to the replace string for each src bundled subpackage

For further reference you can refer to the [History.js](https://github.com/balupton/history.js) [package.json file](https://github.com/balupton/history.js/raw/dev/package.json) which utilises simple bundling and compression, and the [Aloha Editor](https://github.com/alohaeditor/Aloha-Editor) [package.json file](https://github.com/alohaeditor/Aloha-Editor/raw/0.10/package.json) which utilises bundling for both the src and out packages, subpackages and javascript+css+image compression.

s
## License

Licensed under the [MIT License](http://creativecommons.org/licenses/MIT/)
Copyright 2011 [Benjamin Arthur Lupton](http://balupton.com)


## Todo

1. Make it asynchronous
2. Turn the CSS minifier into it's own project


## History

- v0.3 May 31, 2011
	- Moved to CoffeeScript
	- Made it Asynchronous
	- Better CSS Bundling and Compression

- v0.2 April 2, 2011
	- Stable :)

- v0.1 March 23, 2011
	- Initial Work

