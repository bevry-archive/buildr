# Welcome to Buildr. The JavaScript Package Buildr.


## Installation

	npm install buildr

__Note: if you would like to be able to compress image files, you will also need to follow the installation instructions [here](https://github.com/bentruyman/pulverizr/blob/master/pulverizr.js)__


## Usage

	buildr .


## Configuration

Buildr does not require any configuration by default, but if you would like to configure it you can create a `package.json` file which contains the following keys a `buildr` key:

- `compress`: a boolean value or an object, if an object:
	- `js`: a boolean value
	- `css`: a boolean value
	- `img`: a boolean value
	- `html`: a boolean value

- `bundle`: a boolean value or an object, if an object:
	- `js`: a boolean value or a javascript filename
	- `css`: a boolean value or a css filename
	- `src`: a boolean value; for whether or not we should bundle the source files too

- `directories`: an object
	- `out`: a directory path; of where the compiled files will go
	- `src`: a directory path; of where source files come from

- `subpackages`: an array; containing the locations of each subpackage to compress and bundle

- `files`: an object
	- `js`: an array; of javascript files to compress and bundle
	- `css`: an array; of css files to compress and bundle

- `templates`: an object
	- `out-bundle-header.js`: a file path; to the header for the out bundled file
	- `out-bundle-footer.js`: a file path; to the footer for the out bundled file
	- `src-bundle-item.js`: a file path; to the replace string for each out bundled file
	- `src-bundle-header.js`: a file path; to the header for the src bundled file
	- `src-bundle-footer.js`: a file path; to the footer for the src bundled file
	- `src-bundle-item.js`: a file path; to the replace string for each src bundled file


## License

Licensed under the [MIT License](http://creativecommons.org/licenses/MIT/)
Copyright 2011 [Benjamin Arthur Lupton](http://balupton.com)


## Todo

1. Make it asynchronous
2. Turn the CSS minifier into it's own project
3. Add image optimisation
4. Support the sweet package json file above

