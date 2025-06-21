/*
* loglevel - https://github.com/pimterry/loglevel
*
* Copyright (c) 2013 Tim Perry
* Licensed under the MIT license.
*/
(function (root, definition) {
    "use strict";
    if (typeof define === 'function' && define.amd) {
        define(definition);
    } else if (typeof module === 'object' && module.exports) {
        module.exports = definition();
    } else {
        root.log = definition();
    }
}(this, function () {
    "use strict";

    // Slightly saner defaults than what you get from `new Date().toString()`
    var getFormattedTimestamp = function() {
        var date = new Date();
        
        // Pad single-digit numbers with leading zeros
        function pad(n) {
            return n < 10 ? '0' + n : n;
        }

        return pad(date.getHours()) + ':' +
               pad(date.getMinutes()) + ':' +
               pad(date.getSeconds()) + '.' +
               (date.getMilliseconds() < 100 ? '0' : '') +
               (date.getMilliseconds() < 10 ? '0' : '') +
               date.getMilliseconds();
    };

    // Cross-browser bind equivalent that works with IE8
    var bindMethod = function(obj, methodName) {
        var method = obj[methodName];
        if (typeof method.bind === 'function') {
            return method.bind(obj);
        } else {
            try {
                return Function.prototype.bind.call(method, obj);
            } catch (e) {
                // Missing bind shim or IE8 + Modernizr, fallback to wrapping
                return function() {
                    return Function.prototype.apply.apply(method, [obj, arguments]);
                };
            }
        }
    };

    // Trace() doesn't print the message in IE, so for that case we need to wrap it
    var traceForIE = function() {
        if (console.log) {
            if (console.log.apply) {
                console.log.apply(console, arguments);
            } else {
                // In old IE, native console methods themselves don't have apply().
                Function.prototype.apply.apply(console.log, [console, arguments]);
            }
        }
        if (console.trace) console.trace();
    };

    // Build the best logging method possible for this env
    // Wherever possible we want to bind, not wrap, to preserve stack traces
    var realMethod = function(methodName) {
        if (methodName === 'debug') {
            methodName = 'log';
        }

        if (typeof console === 'undefined') {
            return false; // No method possible, for now - fixed later by enableLoggingWhenConsoleArrives
        } else if (methodName === 'trace' && isIE) {
            return traceForIE;
        } else if (console[methodName] !== undefined) {
            return bindMethod(console, methodName);
        } else if (console.log !== undefined) {
            return bindMethod(console, 'log');
        } else {
            return noop;
        }
    };

    // These private functions always need `this` to be set properly

    var replaceLoggingMethods = function(level, loggerName) {
        /*jshint validthis:true */
        for (var i = 0; i < logLevels.length; i++) {
            var levelName = logLevels[i];
            this[levelName] = (i < level) ?
                noop :
                this.methodFactory(levelName, level, loggerName);
        }

        // Define log.log as an alias for log.debug
        this.log = this.debug;
    };

    // In old IE versions, the console isn't present until you first open it.
    // We build realMethod() replacements here that regenerate logging methods
    var enableLoggingWhenConsoleArrives = function(methodName, level, loggerName) {
        return function () {
            if (typeof console !== 'undefined') {
                replaceLoggingMethods.call(this, level, loggerName);
                this[methodName].apply(this, arguments);
            }
        };
    };

    // By default, we use closely bound real methods wherever possible, and
    // otherwise we wait for a console to appear, and then try again.
    var defaultMethodFactory = function (methodName, level, loggerName) {
        /*jshint validthis:true */
        return realMethod(methodName) ||
               enableLoggingWhenConsoleArrives.apply(this, arguments);
    };

    var getLogger = function (name) {
        var logger = loggers[name] || new Logger(
          name, undefined, undefined
        );
        loggers[name] = logger;
        return logger;
    };

    var Logger = function (name, level, methodFactory) {
        // Private logger state. Not to be altered by libraries consuming loglevel
        var self = this;
        var currentLevel;
        var storageKey = "loglevel";
        if (typeof name === "string") {
            storageKey += ":" + name;
        } else if (typeof name === "symbol") {
            storageKey = undefined;
        }

        function persistLevelIfPossible(levelNum) {
            var levelName = (logLevels[levelNum] || 'SILENT').toUpperCase();

            if (typeof window === 'undefined' || !storageKey) return;

            // Use localStorage if available
            try {
                window.localStorage[storageKey] = levelName;
                return;
            } catch (ignore) {}

            // Use sessionStorage if available
            try {
                window.sessionStorage[storageKey] = levelName;
                return;
            } catch (ignore) {}
        }

        function getPersistedLevel() {
            var storedLevel;

            if (typeof window === 'undefined' || !storageKey) return;

            try {
                storedLevel = window.localStorage[storageKey];
            } catch (ignore) {}

            // Fallback to sessionStorage if localStorage isn't available
            if (typeof storedLevel === 'undefined') {
                try {
                    storedLevel = window.sessionStorage[storageKey];
                } catch (ignore) {}
            }

            // If the stored level is not valid, treat it as if nothing was stored.
            if (self.levels[storedLevel] === undefined) {
                storedLevel = undefined;
            }

            return storedLevel;
        }

        function clearPersistedLevel() {
            if (typeof window === 'undefined' || !storageKey) return;

            // Use localStorage if available
            try {
                window.localStorage.removeItem(storageKey);
                return;
            } catch (ignore) {}

            // Use sessionStorage if available
            try {
                window.sessionStorage.removeItem(storageKey);
                return;
            } catch (ignore) {}
        }

        /*
         *
         * Public logger API - see https://github.com/pimterry/loglevel for details
         *
         */

        self.name = name;

        self.levels = { "TRACE": 0, "DEBUG": 1, "INFO": 2, "WARN": 3,
            "ERROR": 4, "SILENT": 5};

        self.methodFactory = methodFactory || defaultMethodFactory;

        self.getLevel = function () {
            return currentLevel;
        };

        self.setLevel = function (level, persist) {
            if (typeof level === "string" && self.levels[level.toUpperCase()] !== undefined) {
                level = self.levels[level.toUpperCase()];
            }
            if (typeof level === "number" && level >= 0 && level <= self.levels.SILENT) {
                currentLevel = level;
                if (persist !== false) {  // defaults to true
                    persistLevelIfPossible(level);
                }
                replaceLoggingMethods.call(self, level, name);
                if (typeof console === 'undefined' && level < self.levels.SILENT) {
                    return "No console available for logging";
                }
            } else {
                throw "log.setLevel() called with invalid level: " + level;
            }
        };

        self.setDefaultLevel = function (level) {
            currentLevel = getPersistedLevel();
            if (currentLevel == null) {
                currentLevel = level;
            }
            self.setLevel(currentLevel, false);
        };

        self.resetLevel = function () {
            self.setLevel(self.levels.TRACE, false);
            clearPersistedLevel();
        };

        self.enableAll = function(persist) {
            self.setLevel(self.levels.TRACE, persist);
        };

        self.disableAll = function(persist) {
            self.setLevel(self.levels.SILENT, persist);
        };

        // Initialize with the right level
        var initialLevel = getPersistedLevel();
        if (initialLevel == null) {
            initialLevel = level == null ? "WARN" : level;
        }
        self.setLevel(initialLevel, false);
    };

    /*
     *
     * Top-level API
     *
     */

    var defaultLogger = new Logger();

    var _logLevels = defaultLogger.levels;
    var logLevels = Object.keys(_logLevels);
    var loggers = {};
    var isIE = (typeof window !== 'undefined') && window.attachEvent && !window.addEventListener;
    var noop = function() {};

    var api = {
        get default() { return defaultLogger; },
        get levels() { return _logLevels; },
        get methodFactory() { return defaultLogger.methodFactory; },

        // Grab the current global log variable in case of overwrite
        noConflict: (function() {
            var _log = typeof window !== 'undefined' ? window.log : undefined;
            return function () {
                if (typeof window !== 'undefined' && window.log === api) {
                    window.log = _log;
                }
                return api;
            };
        })(),

        getLogger: getLogger
    };

    // Add proxy methods to the default logger
    logLevels.forEach(function(level) {
        api[level] = function() {
            return defaultLogger[level].apply(defaultLogger, arguments);
        };
    });

    // Define log.log as an alias for log.debug
    api.log = api.debug;

    // Support for the various types of loglevel import
    api.getLevel = defaultLogger.getLevel;
    api.setLevel = defaultLogger.setLevel;
    api.setDefaultLevel = defaultLogger.setDefaultLevel;
    api.resetLevel = defaultLogger.resetLevel;
    api.enableAll = defaultLogger.enableAll;
    api.disableAll = defaultLogger.disableAll;

    return api;
}));