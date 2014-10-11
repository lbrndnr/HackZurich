/**
 * Express configuration
 */

'use strict';

var express = require('express');
var morgan = require('morgan');
var compression = require('compression');
var bodyParser = require('body-parser');
var methodOverride = require('method-override');
var cookieParser = require('cookie-parser');
var errorHandler = require('errorhandler');
var path = require('path');
var config = require('./environment');
var passport = require('passport');

module.exports = function(app) {
  var env = app.get('env');

  app.set('views', config.root + '/server/views');
  app.engine('html', require('ejs').renderFile);
  app.set('view engine', 'html');
  app.use(compression());
  app.use(bodyParser.urlencoded({ extended: false }));
  app.use(bodyParser.json());
  app.use(methodOverride());
  app.use(cookieParser());
  app.use(passport.initialize());
  app.use(function(req, res, next) {
    console.log("req.query:", JSON.stringify(req.query));
    console.log("req.params:", JSON.stringify(req.params));
    console.log("req.body:", JSON.stringify(req.body));
    console.log("req.header:", JSON.stringify(req.headers));

    next();
  });
  if ('production' === env) {
//    app.use(express.static(path.join(config.root, 'public')));
    app.set('appPath', config.root + '/public');
    app.use(morgan('dev'));
  }

  if ('development' === env || 'test' === env) {
    app.use(require('connect-livereload')());
    //app.use(express.static(path.join(config.root, '.tmp')));
    //app.use(express.static(path.join(config.root, 'client')));
    app.set('appPath', './public');
    app.use(morgan('dev'));
    app.use(errorHandler()); // Error handler - has to be last
  }
};