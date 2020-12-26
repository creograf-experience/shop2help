mongoose = require 'mongoose'
_ = require 'lodash'

Schema = mongoose.Schema
timestamps = require 'mongoose-timestamp'
{ObjectId, Mixed} = mongoose.Schema.Types

{generateOrderCode, generatePromoCode} = require('../services/model-helpers')

OrderSchema = new Schema
  userId:
    type: String
    default: ''

  shopId:
    type: ObjectId
    ref: 'Shop'

  currency:
    type: String
    default: 'RUB'

  convertCurrency:
    type: String

  website_name:
    type: String
    default: 'RUB'

  id:
    type: String
    default: '0'

  advcampaign_id:
    type: Number
    default:0

  status:
    type: String
    enum: [
      'pending'
      'approved'
      'declined'
      'approved_but_stalled'
    ]
    default: 'pending'

  order_id:
    type: String
    default: ''

  cart:
    type: Number
    default: 0

  payment:
    type: Number
    default: 0

  profit:
    type: Number
    default: 0

  convertCart:
    type: Number

  convertPayment:
    type: Number

  positions: [
    product_id: String
    rate: String
    id: Number
    product_url: String
    amount: String
    percentage: Boolean
    datetime: Date
    payment: String
  ]

  processed:
    type: Number
    default: 0

  action_type:
    type: String
    default: ''

  action:
    type: String
    default: ''

  order_date:
    type: Date
    default: ''

  # начисление баланса пользователю по данному заказу
  isCredited:
    type: Boolean
    default: false
  # начисление баланса в ожидании пользователю по данному заказу
  isCreditedProcess:
    type: Boolean
    default: false
  # оставлял ли пользователь коментарий
  isComment:
    type: Boolean
    default: false

module.exports = mongoose.model 'Order', OrderSchema
