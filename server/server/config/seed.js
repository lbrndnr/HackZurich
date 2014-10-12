/**
 * Populate DB with sample data on server start
 * to disable, edit config/environment/index.js, and set `seedDB: false`
 */

'use strict';

var Thing = require('../api/thing/thing.model');
var User = require('../api/user/user.model');
var Feed = require('../api/feed/feed.model');
var Filter = require('../api/filter/filter.model');

Thing.find({}).remove(function() {
  Thing.create({
    name : 'Development Tools',
    info : 'Integration with popular tools such as Bower, Grunt, Karma, Mocha, JSHint, Node Inspector, Livereload, Protractor, Jade, Stylus, Sass, CoffeeScript, and Less.'
  }, {
    name : 'Server and Client integration',
    info : 'Built with a powerful and fun stack: MongoDB, Express, AngularJS, and Node.'
  }, {
    name : 'Smart Build System',
    info : 'Build system ignores `spec` files, allowing you to keep tests alongside code. Automatic injection of scripts and styles into your index.html'
  },  {
    name : 'Modular Structure',
    info : 'Best practice client and server structures allow for more code reusability and maximum scalability'
  },  {
    name : 'Optimized Build',
    info : 'Build process packs up your templates as a single JavaScript payload, minifies your scripts/css/images, and rewrites asset names for caching.'
  },{
    name : 'Deployment Ready',
    info : 'Easily deploy your app to Heroku or Openshift with the heroku and openshift subgenerators'
  });
});

User.find({}).remove(function() {
  User.create({
    provider: 'local',
    name: 'Test User',
    email: 'test@test.com',
    password: 'test'
  }, {
    provider: 'local',
    role: 'admin',
    name: 'Admin',
    email: 'admin@admin.com',
    password: 'admin'
  }, function() {
      console.log('finished populating users');
    }
  );
});

Feed.find({}).remove(function() {
  Feed.create({
    "_id": "507f1f77bcf86cd799439000",
      "user": "507f1f77bcf86cd799439100",
      "name":   "Monkey's calendar",
      "desc":   "Ooo",
      "uri":    "https://www.google.com/calendar/ical/dfjsravtbrn7si9hrl7jcl0d40%40group.calendar.google.com/private-e63a1b6b8d8e732b921f12672ca5056a/basic.ics"
  },
   { "_id": "507f1f77bcf86cd799439001",
     "user": "507f1f77bcf86cd799439100",

     "name":   "Potato in the big city",
      "desc":   "Whassup homies",
      "uri":    "https://www.google.com/calendar/ical/uuvar5p1a250iuu4ntg1mebm5k%40group.calendar.google.com/private-800ff40cbbf0430895b25a9bd06bedff/basic.ics"
  },
  { "_id": "507f1f77bcf86cd799439002",
    "user": "507f1f77bcf86cd799439100",

    "name":   "Schools and bananas",
      "desc":   "Because 7 ate 9",
      "uri":    "http://hz14.the-admins.ch/ics/abc123",
      "filter": "507f1f77bcf86cd799439050"
  },
  { "_id": "507f1f77bcf86cd799439003",
    "user": "507f1f77bcf86cd799439100",
    "name":   "Important only",
      "desc":   "Just to make sure it actually werks",
      "uri":    "http://hz14.the-admins.ch/ics/nvb567",
      "filter": "507f1f77bcf86cd799439051"
  },  function(err) {
      if(err) throw err;
    }
  );
});

Filter.find({}).remove(function() {
  Filter.create(
     {
       "_id": "507f1f77bcf86cd799439050",
      "output": "507f1f77bcf86cd799439002",
      "inputs": ["507f1f77bcf86cd799439000", "507f1f77bcf86cd799439001"],
      "rules": [
      {
        "_type": 1, // # / text,
        "text": 'important',
        "in_body": true,
        "in_subject": true
      }
    ]
  },
  {
    "_id": "507f1f77bcf86cd799439051",
      "output": "507f1f77bcf86cd799439003",
      "inputs": ["507f1f77bcf86cd799439000", "507f1f77bcf86cd799439002"],
      "rules": [
      {
        "_type": 0, // # / text,
        "text": 'banana',
        "in_body": true,
        "in_subject": true
      },
      {
        "_type": 1, // # / text,
        "text": 'school',
        "in_body": true,
        "in_subject": true
      }
    ]
  },  function(err) {
      if(err) throw err;
    }
  );
});