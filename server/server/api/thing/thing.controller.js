'use strict';

var request  = require('request'),
    parallel = require('node-parallel'),
    alphacal = 'https://www.google.com/calendar/ical/dfjsravtbrn7si9hrl7jcl0d40%40group.calendar.google.com/private-e63a1b6b8d8e732b921f12672ca5056a/basic.ics',
    betacal  = 'https://www.google.com/calendar/ical/uuvar5p1a250iuu4ntg1mebm5k%40group.calendar.google.com/private-800ff40cbbf0430895b25a9bd06bedff/basic.ics',
    rules    = [
        {
            type: 0, // # / text,
            text: 'banana',
            in_body: true,
            in_subject: true
        },
        {
            type: 1, // # / text,
            text: 'school',
            in_body: true,
            in_subject: true
        },
    ];

exports.index = function(req, res) {

    res.set('Content-Type', 'text/plain; charset=UTF-8');

    var waitgroup = requestParallel([alphacal, betacal]);

    waitgroup.done(function(error, results) {

        if(typeof error !== 'undefined' && error !== null)  {
            res.send(null);
        }

        var events = aggregateEvents(results);

        res.send(events.join('\n\n\n'));

    });
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

function requestParallel(urls) {

    var waitgroup = new parallel();

    waitgroup.timeout(3000);

    urls.forEach(function(url) {

        waitgroup.add(function(done){

            request(url, function(error, response, body) {

                done(error, response);

            });

        });

    });

    return waitgroup;
}

function extractEvents(body) {

    var events = [];

    for(var e = nextEvent(body); body.length > 0; e = nextEvent(body)) {

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