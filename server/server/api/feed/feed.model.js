'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema,
    Filter = mongoose.Filter;

var FeedSchema = new Schema({
  name: {type: String, required:true},
  user: {type: Schema.Types.ObjectId, ref: 'User', required:true},
  desc: String,
  uri: {type: String, required:true},
  filter: {type: Schema.Types.ObjectId, required:false} // TODO ref: 'Filter',
});

module.exports = mongoose.model('Feed', FeedSchema);