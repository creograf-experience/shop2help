request = require 'request'
mongoose = require 'mongoose'
async = require 'async'

module.exports =
  connectDb: (done) ->
    mongoose.connect 'mongodb://localhost/vitalcms_test'
    mongoose.connection.on "error", (err) -> console.log err
    mongoose.connection.once "open", done

  disconnectDb: (done) ->
    mongoose.connection.close done

  seedDb: (done) ->
    -> async.series seed, done

  prepareDb: (seed) ->
    (done) ->
      return done() unless mongoose.connection.readyState

      async.each Object.keys(mongoose.connection.collections),
      ((name, next) ->
        collection = mongoose.connection.collections[name]
        collection.drop next
      ), ->
        async.series seed, done
