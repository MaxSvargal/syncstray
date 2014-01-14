require("coffee-script");
var gui = require('nw.gui'),
    syncstray = require('./lib/main'),
    args = process.argv.slice(2);

syncstray.initialize(args, gui);