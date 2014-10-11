'use strict';

// Production specific configuration
// =================================
module.exports = {
  // Server IP
  ip:       process.env.CI_IP,

  // Server port
  port:     process.env.CI_PORT,

  // MongoDB connection options
  mongo: {
    uri:    process.env.CI_MONGODB
  }
};