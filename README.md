# Welcome to Buildr. The JavaScript Package Buildr.


## Installation

1. To install buildr, you first need Node.js and NPM installed, if you do not have them installed run the following:

	- On OSX
		
		1. [Install Git](http://git-scm.com/download)

		2. [Install Xcode](http://itunes.apple.com/us/app/xcode/id422352214?mt=12&ls=1)

		3. Run the following in terminal
			
				sudo chown -R $USER /usr/local
				git clone https://github.com/joyent/node.git && cd node && git checkout v0.4.7 && ./configure && make && sudo make install && cd .. && rm -Rf node
				curl http://npmjs.org/install.sh | sh
		
	- On Apt Linux

			sudo chown -R $USER /usr/local
			sudo apt-get update && sudo apt-get install curl build-essential openssl libssl-dev git
			git clone https://github.com/joyent/node.git && cd node && git checkout v0.4.7 && ./configure && make && sudo make install && cd .. && rm -Rf node
			curl http://npmjs.org/install.sh | sh
	
	- On Yum Linux
			
			sudo chown -R $USER /usr/local
			sudo yum -y install tcsh scons gcc-c++ glibc-devel openssl-devel git
			git clone https://github.com/joyent/node.git && cd node && git checkout v0.4.7 && ./configure && make && sudo make install && cd .. && rm -Rf node
			curl http://npmjs.org/install.sh | sh

2. To install buildr globally with NPM v1

		npm -g install buildr

3. If you would also like to enable image compression, run the following

	- On OSX

			npm -g install pulverizr-bal
			ruby -e "$(curl -fsSLk https://gist.github.com/raw/323731/install_homebrew.rb)"
			brew install gifsicle libjpeg optipng pngcrush
	
	- On Apt Linux
			
			npm -g install pulverizr-bal
			sudo apt-get update && sudo apt-get install gifsicle libjpeg-progs optipng pngcrush
	
	- On Yum Linux
			
			sudo yum -y install gifsicle libjpeg-progs optipng pngcrush


## Usage

In the javascript program which you would like to buldr, run the following in terminal:

	buildr .


## Configuration

Buildr does not require any configuration by default, but if you would like to configure it you can create a `package.json` file which contains the following keys a `buildr` key:

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
	- `img`: a boolean value or array; of css files to compress and bundle

- `templates`: an object
	- `out_bundle_header.js`: a file path; to the header for the out bundled file
	- `out_bundle_footer.js`: a file path; to the footer for the out bundled file
	- `out_bundle_item.js`: a file path; to the replace string for each out bundled file
	- `out_bundle_subpackage.js`: a file path; to the replace string for each out bundled subpackage
	- `src_bundle_header.js`: a file path; to the header for the src bundled file
	- `src_bundle_footer.js`: a file path; to the footer for the src bundled file
	- `src_bundle_item.js`: a file path; to the replace string for each src bundled file
	- `src_bundle_subpackage.js`: a file path; to the replace string for each src bundled subpackage

For reference you can refer to the [History.js](https://github.com/balupton/history.js) [package.json file](https://github.com/balupton/history.js/raw/dev/package.json) which utilises simple bundling and compression, and the [Aloha Editor](https://github.com/alohaeditor/Aloha-Editor) [package.json file](https://github.com/alohaeditor/Aloha-Editor/raw/0.10/package.json) which utilises bundling for both the src and out packages, subpackages and javascript+css+image compression.


## License

Licensed under the [MIT License](http://creativecommons.org/licenses/MIT/)
Copyright 2011 [Benjamin Arthur Lupton](http://balupton.com)


## Todo

1. Make it asynchronous
2. Turn the CSS minifier into it's own project

