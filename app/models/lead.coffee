mongoose = require 'mongoose'
Schema = mongoose.Schema
Status = mongoose.model 'Status'
timestamps = require 'mongoose-timestamp'

LeadSchema = new Schema
  name:
    type: String
    required: true
    trim: true
    default: ''
  phone:
    type: String
    trim: true
    default: ''
  theme:
    type: String
    trim: true
    default: ''
  email:
    type: String
    trim: true
    default: ''
  nextDate: Date
  nextStep:
    type: String
    trim: true
    default: ''
  status: String

LeadSchema.plugin timestamps

LeadSchema.index createdAt: 1

LeadSchema.pre 'save', (next) ->
  unless @status
    Status.findOne().exec (err, statuses) =>
      if statuses
        @status = statuses.items[0].name
      next()
  else
    next()

module.exports = mongoose.model 'Lead', LeadSchema
