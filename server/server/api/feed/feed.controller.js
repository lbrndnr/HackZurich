'use strict';

var _ = require('lodash');
var Feed = require('./feed.model');
var Filter = require('./../filter/filter.model');
var User = require('./../user/user.model');

var resolveFilter = function (feed, callback) {
  if (feed.filter) {
    Filter.findById(feed.filter, function (err, filter) {
      if (err) throw err;
      feed.filter = filter;
      console.log(filter);
      callback(feed);
    });
  } else {
    callback(feed);
  }
};

var resolveFilters = function (feeds, callback) {
  Filter.find(function (err, filters) {
    callback(_.map(feeds, function (feed) {
      if(!feed.filter) return feed;
      var f = feed.toObject();
      f.filter = _.find(filters, {_id: feed.filter});
      console.log(f.filter);
      return f;
    }));
  });
};

// Get list of feeds
exports.index = function(req, res) {
  Feed.find({user: req.user._id}, "-user -__v", function (err, feeds) {
    if (err) return handleError(res, err);

    resolveFilters(feeds, function (feeds) {
      res.json(200, {feeds: feeds});
    });
  });
};

// Get a single feed
exports.show = function(req, res) {
  Feed.findById(req.params.id, function (err, feed) {
    if(err) { return handleError(res, err); }
    if (!feed || feed.user.toString() !== req.user._id.toString()) {
      return res.send(404);
    }

    return res.json(feed);
  });
};
// Creates a new feed in the DB.
exports.create = function(req, res) {
  var a = _.merge(req.body, {user: req.user._id});
  a.uri = a.uri || "http://";
  delete a._id;
  delete a.filter._id;
  var f = a.filter;

  var filter_input_ids = [];
  var waitnum = f.inputs.length;

  var final_callback = function () {
    f.inputs = filter_input_ids;

    Filter.create(new Filter(f), function (err, filter) {
      if (err) return handleError(res, err);

      a.filter = filter._id;
      // create the feed
      Feed.create(new Feed(a), function (err, feed) {
        if (err) {
          return handleError(res, err);
        }
        // link feed in filter
        filter.output = feed._id;
        filter.save(function (err) {
          if (err) {
            return handleError(res, err);
          }
          // send back the feed with id n stuff
          resolveFilter(feed, function (feed2) {
            res.json(201, feed2);
          });
        });
      });
    });
  };

  _.each(f.inputs, function (input) {
    if (!input._id) {
      delete input._id;
      console.log(input);
      Feed.create(new Feed(_.merge(input, {user: req.user._id})), function (err, feed) {
        if (err) return console.log("filter save error", err);
        waitnum--;
        filter_input_ids.push(feed._id);
        if (waitnum === 0) final_callback();
      });
    } else {
      filter_input_ids.push(input._id);
      waitnum--;
      if (waitnum === 0) final_callback();
    }
  });
};

// Updates an existing feed in the DB.
exports.update = function(req, res) {
  if(req.body._id) { delete req.body._id; }

  Filter.findById(req.body.filter._id, function(err, filter) {
    Feed.findById(req.params.id, function (err, feed) {
      if (err) { return handleError(res, err); }
      if (!feed || feed.user.toString() !== req.user._id.toString()) {
        return res.send(404);
      }

      var updated = _.merge(feed, req.body, {filter:filter._id});
      updated.save(function (err) {
        if (err) { return handleError(res, err); }
        return res.json(200, feed);
      });
    });
  });


};

// Deletes a feed from the DB.
exports.destroy = function(req, res) {
  Feed.findById(req.params.id, function (err, feed) {
    if(err) { return handleError(res, err); }
    if (!feed || feed.user.toString() !== req.user._id.toString()) {
      return res.send(404);
    }

    feed.remove(function(err) {
      if(err) { return handleError(res, err); }
      return res.send(204);
    });
  });
};

function handleError(res, err) {
  console.log("feed error: ", err);
  return res.send(500, err);
}