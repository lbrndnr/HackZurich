'use strict';

var router    = require('express').Router(),
    cachePath = '/tmp/caltag';

var _  = require('lodash'),
    fs = require('fs');

module.exports = router;

router.get('/:id', serve);

function serve(req, res, next) {

    var validId = (/^[0-9a-z]+$/i).test('' + req.params.id);

    if(!validId) {
        return res.status(400).send(null); // = bad request
    }

    var cacheTarget = cachePath + '/' + req.params.id + '.ical';

    fs.readFile(cacheTarget, function(error, data) {

        if(error !== null) {
            throw error;
        }

        res.attachment(cacheTarget).send(data);

    });
}