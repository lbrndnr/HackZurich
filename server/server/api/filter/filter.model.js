'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;

var FilterSchema = new Schema({
  name: {type: String, required:true},
  input: [{type: Schema.Types.ObjectId, ref: 'Filter'}],
  output: {type: Schema.Types.ObjectId, ref: 'Filter'},
  rules: [
      {type: Number, text: String, in_body: Boolean, in_subject: Boolean}
  ]
});

module.exports = mongoose.model('Filter', FilterSchema);