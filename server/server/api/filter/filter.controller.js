'use strict';

var _ = require('lodash');
var Filter = require('./filter.model');

// Get list of filters
exports.index = function(req, res) {
  Filter.find(function (err, filters) {
    if(err) { return handleError(res, err); }
    return res.json(200, filters);
  });
};

// Get a single filter
exports.show = function(req, res) {
  Filter.findById(req.params.id, function (err, filter) {
    if(err) { return handleError(res, err); }
    if(!filter) { return res.send(404); }
    return res.json(filter);
  });
};

// Creates a new filter in the DB.
exports.create = function(req, res) {
  Filter.create(req.body, function(err, filter) {
    if(err) { return handleError(res, err); }
    return res.json(201, filter);
  });
};

// Updates an existing filter in the DB.
exports.update = function(req, res) {
  if(req.body._id) { delete req.body._id; }
  Filter.findById(req.params.id, function (err, filter) {
    if (err) { return handleError(res, err); }
    if(!filter) { return res.send(404); }
    var updated = _.merge(filter, req.body);
    updated.save(function (err) {
      if (err) { return handleError(res, err); }
      return res.json(200, filter);
    });
  });
};

// Deletes a filter from the DB.
exports.destroy = function(req, res) {
  Filter.findById(req.params.id, function (err, filter) {
    if(err) { return handleError(res, err); }
    if(!filter) { return res.send(404); }
    filter.remove(function(err) {
      if(err) { return handleError(res, err); }
      return res.send(204);
    });
  });
};

function handleError(res, err) {
  return res.send(500, err);
}