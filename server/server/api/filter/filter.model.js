'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

var FilterSchema = new Schema({
  inputs: [{type: Schema.Types.ObjectId, ref: 'Feed'}],
  output: {type: Schema.Types.ObjectId}, // , ref: 'Feed'
  rules: [
      {_type: Number, text: String, in_body: Boolean, in_subject: Boolean}
  ]
});

module.exports = mongoose.model('Filter', FilterSchema);