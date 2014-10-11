'use strict';

var express = require('express');

var index = require('./thing.controller');
var sync = require('./sync.controller');

var router = express.Router();

router.get('/', index.index);
router.get('/sync', sync.index);

module.exports = router;