{ObjectId} = require('mongoose').Types
users = require('./users')
_ = require 'lodash'

ids = [0..5].map -> new ObjectId()

module.exports = [
  {
    _id: ids[0]
    parent: null
    user:
      _id: users.mlm._id
      login: 'mlm'
    path: "#{ids[0]}/0"
    isActive: true
    isMain: true
    isPaid: false
    isFilled: false
    number: 1
    pos: 0
  }, {
    _id: ids[1]
    user:
      _id: users.vasya._id
      login: 'Vasya'
    parent: ids[0]
    path: "#{ids[0]}/0##{ids[1]}/0"
    isLeft: true
    isActive: true
    isPaid: false
    isFilled: false
    isMain: false
    number: 1
    pos: 1
    closeChildrenCount: 3
  }, {
    _id: ids[2]
    user:
      _id: users.vasya._id
      login: 'Vasya'
    parent: ids[0]
    path: "#{ids[0]}/0##{ids[2]}/1"
    isLeft: false
    isActive: false
    isPaid: false
    isFilled: false
    isMain: false
    number: 2
    pos: 2
  }, {
    _id: ids[3]
    user:
      _id: users.petya._id
      login: 'Petya'
    parent: ids[1]
    path: "#{ids[0]}/0##{ids[1]}/0##{ids[3]}/0"
    isLeft: true
    isActive: true
    isPaid: false
    isFilled: false
    isMain: false
    number: 1
    pos: 3
    closeChildrenCount: 1
  }, {
    _id: ids[4]
    user:
      _id: users.petya._id
      login: 'Petya'
    parent: ids[1]
    path: "#{ids[0]}/0##{ids[1]}/0##{ids[4]}/1"
    isLeft: false
    isActive: false
    isPaid: false
    isFilled: false
    isMain: false
    number: 2
    pos: 4
  }, {
    _id: ids[5]
    user:
      _id: users.petya._id
      login: 'Petya'
    parent: ids[3]
    path: "#{ids[0]}/0##{ids[1]}/0##{ids[3]}/0##{ids[5]}/0"
    isLeft: true
    isActive: false
    isPaid: false
    isFilled: false
    isMain: false
    number: 3
    pos: 7
  }
]
