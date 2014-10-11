'use strict';

var express = require('express');
var passport = require('passport');
var auth = require('../auth.service');
var User = require('../../api/user/user.model');

var router = express.Router();

var authenticate = function(req, res, next) {
  passport.authenticate('local', function (err, user, info) {
    var error = err || info;
    if (error) return res.json(401, error);
    if (!user) return res.json(404, {message: 'Something went wrong, please try again.'});

    user.addToken(req.param('device_token'));

    var token = auth.signToken(user._id, user.role);
    res.json({_id: user._id, email: user.email, access_token: token});

  })(req, res, next);
}

router.post('/login', authenticate);

router.post('/register', function(req, res, next) {
  var newUser = new User({email: req.param('email'), password:req.param('password')}); // todo password verifications
  newUser.register(function(err, user) {
    if(err) return res.json({error:err});

    authenticate(req, res, next);
  });
});

module.exports = router;