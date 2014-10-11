'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema,
    Filter = mongoose.Filter;

var FeedSchema = new Schema({
  name: String,
  desc: String,
  uri: String,
  filter: {type: Schema.Types.ObjectId, ref: 'Filter'}
});

module.exports = mongoose.model('Feed', FeedSchema);