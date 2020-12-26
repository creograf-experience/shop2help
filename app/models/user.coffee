path = require 'path'
mongoose = require 'mongoose'
crate = require 'mongoose-crate'
LocalFS = require 'mongoose-crate-localfs'
ImageMagick = require 'mongoose-crate-imagemagick'
timestamps = require 'mongoose-timestamp'
mailer = require '../services/mailer'
Schema = mongoose.Schema
crypto = require 'crypto'
async = require 'async'
moment = require 'moment'
_ = require 'lodash'
require('mongoose-currency').loadType(mongoose)
tree = require 'mongoose-path-tree'

{Currency, ObjectId, Mixed} = Schema.Types

maxLength = (max) ->
  (string) ->
    return true unless string
    string.length <= max

minLength = (min) ->
  (string) ->
    return true unless string
    string.length >= min

randomCode = ->
  crypto.randomBytes(4).toString('hex')

randomPin = ->
  _.chain([0..9]).shuffle().take(4).join('').value()

UserSchema = new Schema
  passwordHash: String
  salt:
    type: String
    default: randomCode
  verificationCode:
    type: String
    default: randomCode
  verified:
    type: Boolean
    default: false

  # for reg
  name:
    type: String
    required: 'Имя не может быть пустым'
    default: ''
    validate: [maxLength(50), 'Имя не может быть длиннее 50 символов']
    trim: true

  surname:
    type: String
    default: ''
    validate: [maxLength(50), 'Фамилия не может быть длиннее 50 символов']
    trim: true

  lastname:
    type: String
    default: ''
    validate: [maxLength(50), 'Отчество не может быть длиннее 50 символов']
    trim: true

  email:
    type: String
    default: ''
    trim: true
    # required: 'Адрес почты не может быть пустым'
    # unique: 'email'
    match: [
      /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/
      'Некорректный email']

  gender:
    type: String
    default: ''

  dateOfBirth:
    type: Date
    default: ''

  phoneNumber:
    type: String

  login:
    type: String
    default: ' '
    required: 'Логин не может быть пустым'
    unique: 'login'
  # used by passport. do not change nor delete
  role:
    type: String
    default: 'user'
    trim: true

  charity:
    type: ObjectId
    ref: 'Charity'

  #избранные магазины
  likedShop: []

  # for admins
  ipAddress:
    type: String
    default: ''
    trim: true
  visitedAt: Date
  isBanned:
    type: Boolean
    default: false
  resetPassCode: String

  balance:
    inProcess:
      type: Number
      default: 0
    ready:
      type: Number
      default: 0

  ownTurn:
    type: Number
    default: 0

  turn:
    type: Number
    default: 0

  bankCredentials:
    type: String
    default: ''
    trim: true
  okpay:
    type: String
    default: ''
    trim: true

  userId:
    type: String
    default: ''

  {
    toObject: virtuals: true
    toJSON: virtuals: true
  }

# место для индексов
UserSchema.plugin tree
UserSchema.plugin timestamps

UserSchema.plugin crate,
  storage: new LocalFS
    directory: path.resolve(__dirname, '../../public/images/users')
    webDirectory: '/images/users'
  fields:
    photo: {}
      # processor: new ImageMagick
      #   tmpDir: path.join(process.cwd(), 'tmp')
      #   formats: ['JPEG', 'PNG']
      #   transforms:
      #     thumb:
      #       thumbnail: '160x160^'
      #       format: 'jpg'
      #     profile:
      #       resize: '210x250>'
      #       format: 'jpg'

# без использования виртуальных полей
# пароли из формы потеряются
UserSchema.virtual('password')
.get(-> @_password)
.set (value) ->
  @_password = value
  @passwordHash = @hashPassword(@_password)

UserSchema.virtual('passConfirm')
.get(-> @_passConfirm)
.set (value) -> @_passConfirm = value

UserSchema.path('passwordHash').validate ((value) ->
  return if !@_password && !@_passConfirm && (@vkontakteId || @facebookId || @odnoklassnikiId)
  if @_password || @_passConfirm
    unless (typeof @_password == 'string') && (@_password.length >= 6)
      @invalidate('password', 'Пароль не может содержать менее 6 символов')

    unless @_password == @_passConfirm
      @invalidate('passwordConfirmation', 'Пароль и подтверждение не совпадают')

  if @isNew && !@_password
    this.invalidate('password', 'required')
), null

UserSchema.pre 'save', (next) ->
  return next() unless @isNew

  # defaultPass = randomCode()
  # console.log 'pass', defaultPass
  # @password = defaultPass
  # @passConfirm = defaultPass
  # @login = @email
  @userId = @_id

  next()

UserSchema.methods.hashPassword = (password) ->
  return password unless @salt && password
  crypto.pbkdf2Sync(password, @salt, 10000, 64, null).toString('base64')

UserSchema.methods.authenticate = (password) ->
  return @passwordHash == @hashPassword(password)

UserSchema.methods.updateLastVisit = (ip) ->
  @ipAddress = ip
  @visitedAt = Date.now()

  @save()

UserSchema.statics.register = (body, next) ->
  User = mongoose.model('User')
  # Card = mongoose.model('Card')
  # user = new User(_.omit(body, 'sponsor'))
  user = new User(body)

  # if Object.keys(body).length < 3
  #   return next(name: 'number', message: 'Заполните обязательные поля')

  # unless body.card.number
  #   return next(name: 'number', message: 'Введите номер карты')

  # unless body.card.code
  #   return next(name: 'code', message: 'Введите код активации')

  # unless body.sponsor_card
  #   return next(name: 'code', message: 'Введите номер карты спонсора')

  unless body.login
    return next(name: 'number', message: 'Введите логин')

  unless body.password
    return next(name: 'number', message: 'Введите пароль')

  unless body.password.length > 4
    return next(name: 'number', message: 'Пароль должен содержать не менее 6 символов')
  
  if body.password != body.confirmPass
    return next(name: 'number', message: 'Пароль и подтверждение не совпадают')

  user.password = body.password
  user.passConfirm = body.confirmPass
  
  user.save (err, savedUser) ->
    return next(err) if err
    next(err, savedUser)

  # Card.findOne number: body.card.number, (err, findedCard) ->
  #   unless findedCard
  #     return next(name: 'sponsor', message: 'Карта с таким номером не найдена')

  #   if findedCard.isActivated
  #     return next(name: 'sponsor', message: 'Данная карта уже активирована')

  #   if findedCard.code != body.card.code
  #     return next(name: 'sponsor', message: 'Неверный код активации')

  #   if body.sponsor_card
  #     Card.findOne number: body.sponsor_card, (err, sponsorCard) ->
  #       unless sponsorCard
  #         return next(name: 'sponsor', message: 'Карта спонсора с таким номером не найдена')

  #       findedCard.parent = sponsorCard._id
  #       findedCard.isActivated = true

  #       user.password = body.password
  #       user.passConfirm = body.confirmPass
        
  #       user.save (err, savedUser) ->
  #         return next(err) if err
  #         findedCard.owner = savedUser._id
  #         findedCard.save (err, card) ->
  #           next(err, savedUser)
          
  #   else
  #     Card.findOne isMain: true, (err, mainCard) ->
  #       return next(err) if err

  #       findedCard.parent = mainCard._id
  #       findedCard.isActivated = true

  #       user.password = body.password
  #       user.passConfirm = body.confirmPass
        
  #       user.save (err, savedUser) ->
  #         return next(err) if err
  #         findedCard.owner = savedUser._id
  #         findedCard.save (err, card) ->
  #           next(err, savedUser)

# пытаемся найти пользователя по email, генерируем ему код,
# не содержащий урл-специфичных символов и высылаем имейл
# с ящика из настроек
UserSchema.statics.prepareReset = (email, next) ->
  mongoose.model('User').findOne login: email, (err, user) ->
    return next(err) if err
    return next(message: 'Пользователя с таким логином не существует') unless user

    user.resetPassCode = crypto.randomBytes(16).toString('base64').replace(/[=+]/g, '0')
    user.save next

    mailer.resetPassword(user)

UserSchema.statics.changePass = (props, next) ->
  mongoose.model('User').findOne(
    _id: props.id
    resetPassCode: props.code
    (err, user) =>
      return next(err) if err
      return next(message: 'not found') unless user

      user.password = props.pass
      user.passConfirm = props.passConfirm
      user.save next)

UserSchema.statics.checkoutOrder = (user, order, next) ->
  mongoose.model('CmsModule').findOne name: 'main', (err, cmsmodule) ->
    return next(err) if err

    mongoose.model('User').findById(user._id).lean().exec (err, user) ->
      return next(err) if err

      percents = cmsmodule.settings.instantBonus || {}
      percents[0] ?= 4
      percents[1] ?= 3
      percents[2] ?= 0
      percents[3] ?= 0

      ancestors = _.chain(user.path.split('#'))
        .reverse()
        .drop()
        .map((id, i) -> _id: id, lvl: i)
        .filter((ancestor) -> percents[ancestor.lvl])
        .value()

      orderPayment =
        total: order.totalTotal
        user: user
        purpose: "Оплата заказа № #{order.code}"
        isLoading: false
        method: 'внутренний перевод'
        status: 'completed'

      mongoose.model('Payment').create orderPayment, (err) ->
        return next(err) if err

        async.each ancestors, ((ancestor, asyncNext) ->
          mongoose.model('User').findById(ancestor._id).lean().exec (err, ancestorUser) ->
            return asyncNext(err) if err
            return asyncNext() if ancestorUser.isMain

            mongoose.model('Payment').create(
              total: order.total * percents[ancestor.lvl] / 100
              user: ancestorUser
              purpose: "Быстрый бонус #{ancestor.lvl+1} уровня от #{user.login} за заказ №#{order.code}"
              isLoading: true
              method: 'внутренний перевод'
              status: 'completed'
              asyncNext)), next

# finds the price of a token and creates a payment
# on amount equal to tokens price.
# "completed" payment charges the user's balance
# automatically in a middleware (see ./payment.coffee)
UserSchema.statics.checkoutToken = (token, next) ->
  mongoose.model('CmsModule').findOne name: 'main', (err, cmsmodule) ->
    return next(err) if err

    tokenCost = +(cmsmodule.settings.tokenCashedCost || cmsmodule.settings.tokenCost || 0) * 100

    mongoose.model('User').findById(token.user._id).lean().exec (err, user) ->
      return next(err) if err

      mongoose.model('Payment').create(
        total: tokenCost
        user: user
        purpose: "Бонус за закрытие жетона № #{token.number}"
        isLoading: true
        method: 'внутренний перевод'
        status: 'completed'
        next)

# gets a list of users referers with their networths.
# Networth is a sum of all tokens user got in the
# current period + networth of his referers
UserSchema.statics.getReferers = (user, query, next) ->
  mongoose.model('User').find path: new RegExp("#{user._id}"), (err, referers) ->
    return next(err) if err

    if query.createdAt
      if query.createdAt.$gt
        query.createdAt.$gt = new Date(+query.createdAt.$gt)

      if query.createdAt.$lt
        query.createdAt.$lt = new Date(+query.createdAt.$lt)

    mongoose.model('Token').getNetworths referers, _.omit(query, 'direct'), (err, referers) ->
      return next(err) if err

      netObject = _.find referers, (referer) ->
        referer._id.equals(user._id)

      networth = netObject && netObject.networth || 0
      ownNetworth = netObject && netObject.ownNetworth || 0

      directRegex = new RegExp("#{user._id}#[0-9a-f]{24}$", 'i')
      referers = referers.filter (referer) ->
        !referer._id.equals(user._id) && (!query.direct || directRegex.test(referer.path))

      next(null, networth: networth, ownNetworth: ownNetworth, referers: referers)

# search by phone, email, login and add networths
# to the result
UserSchema.statics.search = (query, next) ->
  query = _.clone(query)
  _.each query, (value, key) ->
    query[key] = new RegExp(value)
  query.isMain = $ne: true

  mongoose.model('User').find query, (err, users) ->
    return next(err) if err

    mongoose.model('Token').getNetworths users, {}, next

module.exports = mongoose.model 'User', UserSchema
