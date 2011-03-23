// Prepare
var
	Buildr = require('buildr').Buildr,
	myBuildr = new Buildr(process.argv[2]||__dirname);

// Run
myBuildr.run();
