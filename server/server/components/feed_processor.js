'use strict';

var request  = require('request'),
    parallel = require('node-parallel'),
    promise  = require('promise');

module.exports.requestParallel = function(uris) {

    var waitgroup = requestParallel(uris);

    return new promise(function(resolve, reject) {

        waitgroup.done(function(error, results) {

            if(typeof error !== 'undefined' && error !== null)  {
                reject(error);
                return;
            }

            resolve(results);

        });

    });
};

module.exports.extractEvents = function(text) {

    return extractEvents(text);

};


function aggregateEvents(responses) {

     var events = [];

    responses.forEach(function(response) {

        extractEvents(response.body).forEach(function(e) {

            var filtered = filterEvent(e, rules);

            if(filtered === null) {
                return true; // continue
            }

            events.push(filtered);

        });

    });

    return events;

}

function requestParallel(uris) {

    var waitgroup = new parallel();

    waitgroup.timeout(3000);

    uris.forEach(function(uri) {

        waitgroup.add(function(done){

            request(uri, function(error, response, body) {

                done(error, response);

            });

        });

    });

    return waitgroup;
}

function extractEvents(body) {

    var events = [];

    // in case of bug, replace e[1] with body in for-condition hehe
    for(var e = nextEvent(body); e[1].length > 0; e = nextEvent(body)) {

        events.push(e[1]);

        body = e[2];
    }

    return events;
}

function filterEvent(e, rules) {

    if(e.length === 0) {
        return null;
    }

    var lines   = e.replace(/\r\n /g, '').split(/\r\n/),
        subject = '',
        body    = '';

    for(var i = 0, l = lines.length; i < l; i++) {

        var line = lines[i];

        if(line.substr(0, 12) === 'DESCRIPTION:') {
            subject = line.substr(12);
        }

        if(line.substr(0, 8) === 'SUMMARY:') {
            body = line.substr(8);
        }
    }

    if(rules.length === 0) {
        return e;
    }

    for(var i = 0, l = rules.length; i < l; i++) {

        var rule = rules[i];

        if(rule.in_subject && applyRule(rule, subject)) {
            return e;
        }

        if(rule.in_body && applyRule(rule, body)) {
            return e;
        }

    }

    return null;
}

function applyRule(rule, text) {

    var lookup = rule.text;

    if(rule.type === 0) {
        lookup = '#' + lookup;
    }

    return (text.toLowerCase().indexOf(lookup.toLowerCase()) !== -1);

}

function nextEvent(body) {

    var start = 'BEGIN:VEVENT',
        end   = 'END:VEVENT\r\n';

    var off = 0;

    while(body.substr(off, start.length) !== start) {

        off++;

        if(off >= body.length) {
            break;
        }

    }

    var len = 0;

    while(body.substr(off,len).substr(-end.length) !== end) {

        len++;

        if((off+len) >= body.length) {
            break;
        }
    }

    return [
        body.substr(0, off),   // before event
        body.substr(off, len), // event
        body.substr(off+len)   // after event
    ];
}