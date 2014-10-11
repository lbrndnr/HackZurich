'use strict';

exports.index = function(req, res) {

    res.set('Content-Type', 'text/plain; charset=UTF-8');

    res.send('we moved!');
};
