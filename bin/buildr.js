#!/usr/bin/env node

// Prepare
var
	Buildr = require('buildr').Buildr,
	myBuildr = new Buildr(process.argv[2]||'.');

// Run
myBuildr.run();
