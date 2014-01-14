require("coffee-script");
var vksync = require('./lib/main'),
    args = process.argv.slice(2);

gui = require('nw.gui');
vksync.initialize(args, gui);