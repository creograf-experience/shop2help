mongoose = require 'mongoose'
timestamps = require 'mongoose-timestamp'
Schema = mongoose.Schema
{ObjectId} = Schema.Types
async = require 'async'

{generateOrderCode} = require('../services/model-helpers')

PaymentSchema = new Schema
  total:
    type: Number
    required: 'Укажите сумму'

  comment:
    type: String
    default: ''
    trim: true

  number:
    type: String
    default: ''
    trim: true

  user:
    type: ObjectId
    ref: 'User'
    default: null

  fromUser:
    type: ObjectId
    ref: 'User'
    default: null

  date:
    type: Date
    default: Date.now()

  status:
    type: String
    default: 'completed'

  purpose:
    type: String
    default: 'cashback'
  
  charity:
    type: ObjectId
    ref: 'Charity'

  {
    toObject: virtuals: true
    toJSON: virtuals: true
  }


PaymentSchema.pre 'save', (next) ->
  return next() if @status != 'completed'

  # if @purpose == 'bonus'
  #   mongoose.model('User')
  #     .findOneAndUpdate(
  #       { _id: @user }, 
  #       { $inc:'balance.ready': @total }
  #     )
  #     .exec (err, user) ->
  #       return console.error err if err

  #       query =
  #         _id: user.charity
  #       mongoose.model('Charity')
  #         .findOne(query)
  #         .exec (err, charity) ->
  #           charity.balance += @total
  #           charity.save()

  #   return next()
  # else
  userId = @user
  updatedUser = @user
  total = @total

  CmsModule = require('mongoose').model('CmsModule')
  Payment = require('mongoose').model('Payment')

  CmsModule.findOne(name: 'main').exec (err, mainModule) ->
    if err || !mainModule || !mainModule.settings
      return message: "Can't find the main module or its settings"
    
    percents = mainModule.settings.instantBonus || {}
    
    mongoose.model('User')
      .findOneAndUpdate(
        { _id: updatedUser }, 
        { $inc: 'balance.ready': total, 'ownTurn': total }
      )
      .exec (err, user) ->
        return console.error err if err

        query =
          _id: user.charity
        mongoose.model('Charity')
          .findOne(query)
          .exec (err, charity) ->
            return console.error(err) if err
            charity.balance += total
            charity.save()

      #для каждого уровня бонусов
      # async.eachSeries percents, ((percent, callback) ->
        # getParent userId, (ancestor) ->
        #   #если есть родитель на этом уровне
        #   if ancestor
        #     userId = ancestor._id

        #     paymentBonus = new Payment
        #       total: (+total * +percent / 100)
        #       purpose: 'bonus'
        #       status: 'completed'
        #       user: userId
        #       fromUser: updatedUser
        #       comment: "Быстрый бонус #{percents.indexOf(percent) + 1} уровня"

        #     return paymentBonus.save callback
        #   else
          #   return callback()
            
      # ), (err) ->
        # mongoose.model('User')
        #   .findOneAndUpdate(
        #     { _id: updatedUser }, 
        #     { $inc: 'balance.ready': total, 'ownTurn': total }
        #   )
        #   .exec (err, user) ->
        #     return console.error err if err

        #     query =
        #       _id: user.charity
        #     mongoose.model('Charity')
        #       .find(query)
        #       .exec (err, charity) ->
        #         charity.balance += total
        #         charity.save()
            
  return next()

# getParent = (id, next) ->
#   Card = require('mongoose').model('Card')
#   User = require('mongoose').model('User')

#   Card.findOne owner: id, (err, card) ->
#     Card.findOne _id: card.parent, (err, parentCard) ->
#       if !parentCard
#         return next(null)
#       if parentCard.isMain
#         return next(null)
#       User.findOne _id: parentCard.owner, (err, parent) ->
#         return next(parent)

module.exports = mongoose.model('Payment', PaymentSchema)
