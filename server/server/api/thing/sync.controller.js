'use strict';


var _ = require('lodash'),
    fs = require('fs'),
    fp = require('../../components/feed_processor');
var Filter = require('./../filter/filter.model');
var Feed = require('./../feed/feed.model');
var app = require('../../app');
var cachePath = "/home/hz14/dist/public/ics";


/* feeds collection, key is id */
var feeds = {};
/* filter collection, key is id */
var filters = {};

exports.index = function (req, res) {

  var processed = {};
  Feed.find(function (err, _feeds) {
    if (err) throw err;
    Filter.find(function (err, _filters) {
      if (err) throw err;

      filters = _.indexBy(_filters, '_id');
      feeds = _.indexBy(_feeds, '_id');

      _.forEach(filters, function (filter) {

        if (typeof processed[filter._id] !== 'undefined') {
          return true; // continue
        }
        processFilter(filter, processed);
      });

      res.send(null);
    });

  });

};

/**
 * recursively process filters in order of dependency
 */
function processFilter(filter, processed) {
  // make sure all of our inputs have been processed

  filter.inputs.forEach(function (feedId) {

    var feed = feeds[feedId];

    if (typeof feed !== 'undefined' && typeof feed.filter !== 'undefined' && typeof processed[feed.filter] === 'undefined') {
      processFilter(filters[feed.filter], processed);

    }

  });

  // inputs ready, do actual processing

  var uris = filter.inputs.map(function (feedId) {
    var feed = feeds[feedId];
    if (typeof feed !== 'undefined') {
      return feeds[feedId].uri;
    }
  });

  fp.requestParallel(uris).then(
    function (responses) {
      var keepEvents = [];

      responses.forEach(function (response) {

        // TODO(twilde): check response's status code

        fp.extractEvents(response.body).forEach(function (eventText) {

          if (fp.filterEvent(eventText, filter.rules)) {
            keepEvents.push(eventText);
          }

        });

      });
      var cacheTarget = cachePath + '/' + filter._id + '.ical',
          cacheContent = icalTemplate(feeds[filter.output], keepEvents);
      console.log(cacheTarget);
      fs.writeFile(cacheTarget, cacheContent, function (error) {
        if (error !== null) {
          throw error;
        }
      });
    },
    function (error) {
      throw error; // TODO(twilde): better error handling?
    }
  );

  // must run, always
  processed[filter._id] = true;

}

/**
 * TODO(twilde): encode feed name and desc correctly.
 */
function icalTemplate(outFeed, events) {
  return [
    'BEGIN:VCALENDAR',
    'PRODID:-//caltag//caltag 1.0//EN',
    'VERSION:2.0',
    'CALSCALE:GREGORIAN',
    'METHOD:PUBLISH',
      'X-WR-CALNAME:' + outFeed.name,
    'X-WR-TIMEZONE:Europe/Zurich',
      'X-WR-CALDESC:' + outFeed.desc,
    'BEGIN:VTIMEZONE',
    'TZID:Europe/Zurich',
    'X-LIC-LOCATION:Europe/Zurich',
    'BEGIN:DAYLIGHT',
    'TZOFFSETFROM:+0100',
    'TZOFFSETTO:+0200',
    'TZNAME:CEST',
    'DTSTART:19700329T020000',
    'RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=-1SU',
    'END:DAYLIGHT',
    'BEGIN:STANDARD',
    'TZOFFSETFROM:+0200',
    'TZOFFSETTO:+0100',
    'TZNAME:CET',
    'DTSTART:19701025T030000',
    'RRULE:FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU',
    'END:STANDARD',
    'END:VTIMEZONE',
    ''

  ].join('\r\n') + events.join('') + 'END:VCALENDAR';
}