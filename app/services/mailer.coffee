nodemailer = require 'nodemailer'
smtpTransport = require 'nodemailer-smtp-transport'
moduleModule = require '../models/cmsmodule'
mongoose = require 'mongoose'
CmsModule = mongoose.model 'CmsModule'
_ = require 'lodash'

config =
  domain: process.env.domain || 'localhost:3011'

module.exports =
  transporter: null
  mailOptions: {}

  reinit: ->
    CmsModule.findOne(name: 'main').exec (err, mainModule) =>
      if err || !mainModule || !mainModule.settings || !mainModule.settings.mailer
        return message: "Can't find the main module or its settings"
      settings = mainModule.settings.mailer
      @transporter = nodemailer.createTransport(
        smtpTransport
          host: settings.smtpServer
          port: 587,
          secure: false,
          auth:
            user: settings.user
            pass: settings.pass
      )

      @mailOptions =
        adminMail: mainModule.settings.adminMail
        managerMail: mainModule.settings.managerMail
        from: settings.from

  send: (options, done) ->
    # unless @transporter
    #   return done(new Error "Can't find the mail transporter")
    # if !options.to || !options.text
    #   return done(new Error "You need to specify receiver and text.")

    options ?= {}
    _.extend options, @mailOptions

    @transporter.sendMail options, (err, info) ->
      console.log err if err
      console.log info if info

  notifyAdmin: (message, subject) ->
    return if process.env.NODE_ENV == 'test'
    @send
      to: @mailOptions.adminMail
      text: message
      subject: subject || ''

  notifyManager: (lead) ->
    message = "ФИО: #{lead.name}\n
      Телефон: #{lead.phone}\n
      Email: #{lead.email}\n
      Тема: #{lead.theme || ''}\n
      Сообщение: #{lead.comment}"
    @send
      to: @mailOptions.managerMail
      text: message
      subject: lead.theme || 'Вопрос на сайте Ayratex.com'

  newCallback: (callback) ->
    message = "ФИО: #{callback.name}\n
      Email: #{callback.email}\n
      Сообщение: #{callback.body}"
    @send
      to: @mailOptions.managerMail
      text: message
      subject: 'Вопрос на сайте  Cashandback.ru'

  resetPassword: (user) ->
    return if process.env.NODE_ENV == 'test'

    message = "Перейдите по ссылке для того, чтобы сбросить пароль:\n
      http://shop2help.ru/auth/resetpass?id=#{user._id}&code=#{user.resetPassCode}"
    @send
      to: user.email.toString()
      text: message
      subject: 'Смена пароля'

  cartNotifyManager: (order) ->
    return unless @mailOptions.managerMail

    message = "Заказ на сумму #{(order.totalTotal / 100).toFixed(2)} руб.\n
      номер заказа: #{order.code}\n
      покупатель: #{order.name}\n
      телефон: #{order.phone}\n
      email: #{order.email}"

    if !order.selfDelivery && (order.city || order.address)
      message += "\nАдрес доставки: #{order.city || ''}, #{order.address || ''}"
    @send
      to: @mailOptions.managerMail
      subject: "Заказ №#{order.code}"
      text: message

  cartNotifyCustomer: (order) ->
    message = "Здравствуйте, #{order.name}!\n
    Вы оплатили заказ на сумму #{order.totalTotal / 100} руб:\n
    Вам начислено #{order.tokens} жетонов.\n
    \n
    С Уважением,\n
    администрация сайта\n"
    @send
      to: order.email
      subject: "#{config.domain}. Заказ №#{order.code}"
      text: message

  generateCards: (list) ->
    message = "Начислены карты доступа:\n"
    for card in list.cards
      message += "Номер: #{card.number}  Код активации: #{card.code}\n"
    message += "\n
    С Уважением,\n
    администрация сайта\n"
    @send
      to: list.email
      subject: "Карты доступа cashandback.ru"
      text: message

  verifyReg: (user) ->
    message = "Здравствуйте, #{user.name} #{user.lastname}!\n
      Вы зарегистрированы на сайте Shop2Help.ru Для продолжения работы, необходимо подтвердить регистрацию, перейдя по ссылке.\n
      http://shop2help.ru/auth/verify?userId=#{user._id}&&code=#{user.verificationCode}\n
      \n
      После подтверждения регистрации используйте для входа на сайт:\n
      логин: #{user.login}\n
      пароль: #{user.password}\n
      Никому не передавайте свой пароль."

    @send
      to: user.email
      subject: "Подтверждение регистрации на Shop2Help.ru"
      text: message
