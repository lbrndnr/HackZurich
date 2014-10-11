'use strict';

var _ = require('lodash'),
    p = require('../../components/feed_processor');


/* feeds collection, key is id */
var feeds = {
    "def321" : {
        "id":     "def321",
        "name":   "Monkey's calendar",
        "desc":   "Ooo",
        "uri":    "https://www.google.com/calendar/ical/dfjsravtbrn7si9hrl7jcl0d40%40group.calendar.google.com/private-e63a1b6b8d8e732b921f12672ca5056a/basic.ics",
        "filter": null // no filter = external feed
    },
    "jkl789": {
        "id":     "jkl789",
        "name":   "Potato in the big city",
        "desc":   "Whassup homies",
        "uri":    "https://www.google.com/calendar/ical/uuvar5p1a250iuu4ntg1mebm5k%40group.calendar.google.com/private-800ff40cbbf0430895b25a9bd06bedff/basic.ics",
        "filter": null // no filter = external feed
    },
    "abc123": {
        "id":     "abc123",
        "name":   "Schools & Bananas",
        "desc":   "Because 7 ate 9",
        "uri":    "http://hz14.the-admins.ch/api/feeds/abc123",
        "filter": "tre547"
    },
    "nvb567": {
        "id":     "nvb567",
        "name":   "Important only",
        "desc":   "Just to make sure it actually werks",
        "uri":    "http://hz14.the-admins.ch/api/feeds/nvb567",
        "filter": "jhg980"
    }
};

/* filter collection, key is id */
var filters = {
    "jhg980": {
        "id": "jhg980",
        "output": "nvb567",
        "inputs": ["jkl789", "abc123"],
        "rules": [
            {
                "type": 1, // # / text,
                "text": 'important',
                "in_body": true,
                "in_subject": true
            }
        ]
    },
    "tre547": {
        "id": "tre547",
        "output": "abc123",
        "inputs": ["def321", "jkl789"],
        "rules": [
            {
                "type": 0, // # / text,
                "text": 'banana',
                "in_body": true,
                "in_subject": true
            },
            {
                "type": 1, // # / text,
                "text": 'school',
                "in_body": true,
                "in_subject": true
            }
        ]
    }
};


exports.index = function(req, res) {

    res.set('Content-Type', 'text/plain; charset=UTF-8');

    var processed = {};

    _.forEach(filters, function(filter) {

        if(typeof processed[filter.id]  !== 'undefined') {
            return true; // continue
        }

        processFilter(filter, processed);

    });

    res.json(processed);

};

/**
 * recursively process filters in order of dependency
 */
function processFilter(filter, processed) {

    // make sure all of our inputs have been processed
    filter.inputs.forEach(function(feedId) {

        var feed = feeds[feedId];

        if(feed.filter !== null && typeof processed[feed.filter] === 'undefined') {

            processFilter(filters[feed.filter], processed);

        }

    });

    // inputs ready, do actual processing

    var uris = filter.inputs.map(function(feedId) {
        return feeds[feedId].uri;
    });

    p.requestParallel(uris).then(
        function(responses) {
            responses.forEach(function(response) {
                p.extractEvents(response.body).forEach(function(eventText) {

                });
            });
        },
        function(error) {
            throw error; // TODO(twilde): better error handling?
        }
    );

    // must run, always
     processed[filter.id] = true;

};