var S = require("string");
var _ = require("lodash");
var path = require("path");
var phantomtask = require.resolve("phantomtask/bin/phantomtask");

var PHANTOM_ARGUMENTS = ["webSecurity", "loadImages", "diskCache", "cookiesFile"];

module.exports = function (options) {
	options = _.extend({}, options || {});

	return function (src, callback) {
		var phantomjs = require("phantomjs").path;
		var args = [];

		_(options).pick(PHANTOM_ARGUMENTS).forOwn(function (value, key) {
			args.push("--" + S(key).dasherize().toString());
			args.push(value);
		});
		
		args.push(phantomtask);

		if (options.parallel) {
			args.push("-p");
		}

		_.forOwn(options.tasks || {}, function (options, file) {
			args.push("-t");
			args.push(file + path.delimiter + JSON.stringify(options));
		});

		_([].concat(options.inject || [])).forIn(function (file) {
			args.push("-i");
			args.push(file);
		});

		args.push(src);

		var spawn = require("child_process").spawn;
		var p = spawn(phantomjs, args);
		p.on("exit", function (code) {
			var error;
			if (code !== 0) {
				error = new Error("Phantomjs exited with code: " + code);
			}
			if (typeof callback === "function") {
				callback(error);
			}
		});
		return p;
	};
};
