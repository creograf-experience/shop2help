config = require 'nconf'
path = require 'path'
async = require 'async'
db = require '../app/models'
mongoose = require 'mongoose'
Admin = mongoose.model 'Admin'
Group = mongoose.model 'Group'
Status = mongoose.model 'Status'
Page = mongoose.model 'Page'
Form = mongoose.model 'Form'
CmsModule = mongoose.model 'CmsModule'
User = mongoose.model 'User'
Token = mongoose.model 'Token'
# Card = mongoose.model 'Card'
_ = require 'lodash'

{ObjectId} = mongoose.Types

config.file(file: path.join __dirname, '../config/application.json')

mongoose.connect config.get("database:production")
mongoose.connection.once 'open', ->
  async.parallel [
    seedAdmins
    seedPages
    seedForms
    seedModules
    seedMainUserAndToken
  ], (err) ->
    console.log err if err
    mongoose.disconnect()

seedAdmins = (next) ->
  Group.findOne(name: 'Супервизоры').exec (err, group) ->
    group ?= new Group
      name: 'Супервизоры'
      super: true

    group.save ->
      Admin.findOne(login: 'admin').exec (err, admin) ->
        return next() if admin
        admin = new Admin
          name: 'admin'
          login: 'admin'
          email: 'admin@adminland.hk'
          password: config.get('adminPass')
          fullAccess: true
          groupId: group._id

        admin.save next

seedPages = (next) ->
  Page.find().exec (err, pages) ->
    return next() if pages.length > 0
    Page.create
      title: 'домашняя'
      body: '<p>Заглушка</p>'
      isstart: true
      template: 'simple'
      next

seedForms = (next) ->
  Form.findOne homePage: true, (err, form) ->
    return next() if form
    Form.create
      name: 'опрос'
      homePage: true
      fields: [
        disabled: false
        comment: ''
        required: true
        type: 'radio'
        label: 'Да или нет?'
        name: 'yesno'
        defaultValue: 'да\nнет\nнаверное'], next

seedMainUserAndToken = (next) ->
  seedToken = (user) ->
    # Card.findOne isMain: true, (err, card) ->
    #   return next() if card

    #   User.findOne isMain: true, (err, user) ->
    #     cardId = new ObjectId()
    #     Card.collection.insert(
    #       _id: cardId
    #       parent: null
    #       isActivated: true
    #       isMain: true
    #       number: "1"
    #       owner: user._id
    #       next)
    # Token.findOne isMain: true, (err, token) ->
    #   return next() if token

    #   User.findOne isMain: true, (err, user) ->
    #     tokenId = new ObjectId()
    #     Token.collection.insert(
    #       _id: tokenId
    #       user:
    #         _id: user._id
    #         login: 'mlm'
    #       parent: null
    #       path: "#{tokenId}/0"
    #       isActive: true
    #       isPaid: false
    #       isFilled: false
    #       isMain: true
    #       number: 1
    #       pos: 0
    #       next)

  User.findOne isMain: true, (err, user) ->
    return seedToken(user) if user

    userId = new ObjectId()
    User.collection.insert(
      _id: userId
      path: userId.toString()
      login: 'mlm'
      isMain: true
      parent: null
      seedToken)

seedModules = (next) ->
  CmsModule.find (err, modules) ->
    hasModule = (name) -> !!_.find modules, name: name

    pagesModule =
      name: 'pages'
      settings:
        maxVersions: 10
    mainModule =
      name: 'main'
      settings:
        mailer: from: 'admin@vitalcms.org'
        tokenCost: 100
        tokenCashedCost: 100
        instantBonus: [5, 3, 0, 0]
        nextTime : Date.now() + 1000 * 60 * 60 * 24 * 14
        period : "2weeks"
        qualifications: [{
          name: "1"
          bonus: 4
          limit: 39
          balance: [50, 30, 20]
        }, {
          name: "2"
          limit: 77
          bonus: 8
          balance: [50, 30, 20]
        }, {
          name : "3"
          bonus: 13
          limit: 231
          balance: [50, 30, 20]
        }, {
          name: "4"
          bonus: 18
          limit : 462
          balance: [50, 30, 20]
      }]

    leadsModule =
      name: 'leads'
      settings:
        statuses: [
          'новый'
          'в обработке'
          'отвалился'
          'работаем']
    ordersModule =
      name: 'orders'
      settings:
        statuses: [
          'новый'
          'в обработке'
          'оплачен'
          'завершен']
        paymentTypes: [
          'Курьеру наличными'
          'Перевод']
        deliveryTypes: [
          'Курьером'
          'Самовывоз']
    paymentsModule =
      name: 'payments'
      settings: {}

    async.parallel [
      (nextModule) ->
        return nextModule() if hasModule('pages')
        CmsModule.create pagesModule, nextModule
      (nextModule) ->
        return nextModule() if hasModule('main')
        CmsModule.create mainModule, nextModule
      (nextModule) ->
        return nextModule() if hasModule('orders')
        CmsModule.create ordersModule, nextModule
      (nextModule) ->
        return nextModule() if hasModule('leads')
        CmsModule.create leadsModule, nextModule
      (nextModule) ->
        return nextModule() if hasModule('payments')
        CmsModule.create paymentsModule, nextModule
    ], next
