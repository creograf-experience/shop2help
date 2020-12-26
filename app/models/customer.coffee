crypto = require 'crypto'
mongoose = require 'mongoose'
Schema = mongoose.Schema
_ = require 'lodash'

mailer = require '../services/mailer'

CustomerSchema = new Schema
  passwordHash: String
  salt: String

  # contacts
  name:
    type: String
    trim: true
    default: ''
  phone:
    type: String
    required: 'Номер телефона не может быть пустым'
    trim: true
    default: ''
  email:
    type: String
    required: 'Адрес почты не может быть пустым'
    index: unique: 'Пользователем с таким email уже зарегистрирован'
    trim: true
    default: ''
    match: [
      /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/
      'Некорректный email']

  # company info
  companyName:
    type: String
    trim: true
    default: ''
  inn:
    type: String
    trim: true
    default: ''
    match: [/^[\d \-\.]+$/]

  # delivery info
  address:
    type: String
    trim: true
    default: ''
  deliveryType:
    type: String
    trim: true
    default: ''
  unloadType:
    type: String
    trim: true
    default: ''
  paymentType:
    type: String
    trim: true
    default: ''
  regularCustomerCode:
    type: String
    trim: true
    default: ''
  recieveSpam:
    type: Boolean
    default: false
  discount:
    type: Number
    default: 0
  city: String
  resetPassCode:
    type: String
    trim: true

CustomerSchema.virtual('password')
  .get(-> @_password)
  .set (value) ->
    @_password = value
    @salt = @salt || crypto.randomBytes(16).toString('base64')
    @passwordHash = @hashPassword(@_password)

CustomerSchema.virtual('passConfirm')
  .get(-> @_passConfirm)
  .set (value) -> @_passConfirm = value

CustomerSchema.pre 'save', (next) ->
  if !@discount || (@discount && ((@discount < 0) || (@discount > 100)))
    @discount = 0

  next()

# le spooky skeleton
#   ░░░░░░░░░░░░░░░░▄▐
# ░░░░░░░░░░░▄▄▄░░▄██▄
# ░░░░░░░░░░▐▀█▀▌░░░░▀█▄
# ░░░░░░░░░░▐█▄█▌░░░░░░▀█▄
# ░▄░░░░░░░░░▀▄▀░░░▄▄▄▄▄▀▀
# ▀▄█░░░░░░▄▄▄██▀▀▀▀
# ▀▀█▄░░░░█▀▄▄▄█░▀▀
# ░░░█▄░░░▌░▄▄▄▐▌▀▀▀
# ░░░░█▄░▐░░░▄▄░█░▀▀
# ░░░░░▀█▌░░░▄░▀█▀░▀
# ░░░░░░░░░░░░▄▄▐▌▄▄
# ░░░░░░░░░░░░▀███▀█░▄
# ░░░░░░░░░░░▐▌▀▄▀▄▀▐▄
# ░░░░░░░░░░░▐▀░░░░░░▐▌
# ░░░░░░░░░░░█░░░░░░░░█
# ░░░░░░░░░░▐▌░░░░░░░░░█
# ░░░░░░░░░░█░░░░░░░░░░▐▌
# ░░░░░░░░░░█░░░░░░░░░░██
# ░░░░░░░░░▐█▌░░░░░░░░░░▌▌
# ░░░░░░░░░▐▐░░░░░░░░░░░▐▐
# ░░░░░░░░░▐▐░░░░░░░░░░░▐▐
# ░░░░░░░░░▐▐░░░░░░░░░░░░▌▌
# ░░░░░░░░░▐▐░░░░░░░░░░░░▌▌
# ░░░░░░░░░▐█░░░░░░░░░░░░▀█▄
# ░░░░░░░░▄█▀░░░░░░░░░░░░░░▀▀▀
# ░░░░░░░▀▀

CustomerSchema.path('passwordHash').validate ((value) ->
  if @_password || @_passConfirm
    unless (typeof @_password == 'string') && (@_password.length > 5)
      @invalidate('password', 'Пароль не может содержать менее 6 символов.')

    unless @_password == @_passConfirm
      @invalidate('passwordConfirmation', 'Пароль и подтверждение не совпадают')

  if @isNew && !@_password
    this.invalidate('password', 'required')
  ), null

CustomerSchema.methods.hashPassword = (password) ->
  return password unless @salt && password

  crypto.pbkdf2Sync(password, @salt, 10000, 64, null).toString('base64')

CustomerSchema.methods.authenticate = (password) ->
  return @passwordHash == @hashPassword(password)

CustomerSchema.methods.changePassword = (newPassword, done) ->
  @update(password: @hashPassword(newPassword)).exec (err) ->
    done(err)

CustomerSchema.statics.prepareReset = (email, next) ->
  mongoose.model('Customer').findOne email: email, (err, customer) ->
    return next(err) if err || !customer
    customer.resetPassCode = crypto.randomBytes(16).toString('base64')
    customer.save next

    mailer.resetPassword(customer)

CustomerSchema.statics.changePass = (props, next) ->
  mongoose.model('Customer').findOne(
    _id: props.id
    resetPassCode: props.code
    (err, customer) =>
      return next(err) if err
      return next(message: 'not found') unless customer

      customer.password = props.pass
      customer.passConfirm = props.passConfirm
      customer.save next)

module.exports = mongoose.model('Customer', CustomerSchema)
