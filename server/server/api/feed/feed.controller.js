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
      callback(feed);
    });
  } else {
    callback(feed);
  }
};

var resolveFilters = function (feeds, callback) {
  Filter.find(function (err, filters) {
    callback(_.map(feeds, function (feed) {
      if (!feed.filter) return feed;
      var f = feed.toObject();
      f.filter = _.find(filters, {_id: feed.filter});
      return f;
    }));
  });
};

// Get list of feeds
exports.index = function (req, res) {
  Feed.find({user: req.user._id}, "-user -__v", function (err, feeds) {
    if (err) return handleError(res, err);

    resolveFilters(feeds, function (feeds) {
      res.json(200, {feeds: feeds});
    });
  });
};

// Get a single feed
exports.show = function (req, res) {
  Feed.findById(req.params.id, function (err, feed) {
    if (err) {
      return handleError(res, err);
    }
    if (!feed || feed.user.toString() !== req.user._id.toString()) {
      return res.send(404);
    }

    return res.json(feed);
  });
};
// Creates a new feed in the DB.
exports.create = function (req, res) {
  var a = _.merge(req.body, {user: req.user._id});
  a.uri = a.uri || "http://";
  delete a._id;

  var final_callback = function (filter) {
    // create the feed
    Feed.create(new Feed(a), function (err, feed) {
      if (err) return handleError(res, err);

      if (filter) {
        // link feed in filter
        filter.output = feed._id;
        filter.save(function (err) {
          if (err) {
            return handleError(res, err);
          }
          // send back the feed with id n stuff
          resolveFilter(feed, function (feed) {
            res.json(201, feed);
          });
        });
      } else {
        res.json(201, feed);
      }

    });
  };

  if (a.filter) {
    delete a.filter._id;
    var f = a.filter;
    // create the filter
    Filter.create(new Filter(f), function (err, filter) {
      if (err) return handleError(res, err);

      a.filter = filter._id;
      final_callback(filter);

    });
  } else {
    final_callback();
  }

};

// Updates an existing feed in the DB.
exports.update = function (req, res) {
  if (req.body._id) {
    delete req.body._id;
  }
  var a = req.body;

  var callback = function (filter) {
    Feed.findById(req.params.id, function (err, feed) {
      if (err) {
        return handleError(res, err);
      }
      if (!feed || feed.user.toString() !== req.user._id.toString()) {
        return res.send(404);
      }

      var more_callback = function (savedFilter) {
        var updated = _.merge(feed, a);

        updated.save(function (err) {
          if (err) return handleError(res, err);
          var f = feed.toObject();
          if (savedFilter) {
            f.filter = savedFilter;
          }

          return res.json(200, f);
        });
      };

      if (filter) {
        delete a.filter._id;
        Filter.findByIdAndUpdate(filter._id, a.filter, function (err, savedFilter) {
          if (err) {
            handleError(res, err);
          }
          a.filter = filter._id;
          more_callback(savedFilter);
        });


      } else {
        more_callback();
      }
    });

  };

  if (a.filter) {
    Filter.findById(a.filter._id, function (err, filter) {
      if (err) {
        return handleError(res, err);
      }
      callback(filter);

    });
  } else {
    callback();
  }


};

// Deletes a feed from the DB.
exports.destroy = function (req, res) {
  Feed.findById(req.params.id, function (err, feed) {
    if (err) {
      return handleError(res, err);
    }
    if (!feed || feed.user.toString() !== req.user._id.toString()) {
      return res.send(404);
    }

    feed.remove(function (err) {
      if (err) {
        return handleError(res, err);
      }
      return res.send(204);
    });
  });
};

function handleError(res, err) {
  console.log("feed error: ", err);
  return res.send(500, err);
}