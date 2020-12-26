{ObjectId} = require('mongoose').Types
ids = [0..5].map -> new ObjectId()

module.exports =
  vasya:
    _id: ids[0]
    path: "#{ids[3]}##{ids[0]}"
    parent: ids[3]
    name: 'Vasya'
    surname: 'Vasin'
    lastname: 'Vasilievich'
    login: 'vasya'
    email: 'stepan@gmail.com'
    password: '123123123'
    passConfirm: '123123123'
    isMain: false
    balance: 0

  petya:
    _id: ids[1]
    parent: ids[0]
    path: "#{ids[3]}##{ids[0]}##{ids[1]}"
    name: 'Petya'
    surname: 'Petrov'
    lastname: 'Petrovich'
    login: 'petya'
    email: 'stepan@cyka.com'
    password: '123123123'
    passConfirm: '123123123'
    isMain: false
    balance: 0

  kolya:
    _id: ids[4]
    parent: ids[1]
    path: "#{ids[3]}##{ids[0]}##{ids[1]}##{ids[4]}"
    name: 'Kolya'
    surname: 'Nikolaev'
    lastname: 'Nikolaevich'
    login: 'kolya'
    email: 'stepan@cyka.com'
    password: '123123123'
    passConfirm: '123123123'
    isMain: false
    balance: 0

  misha:
    _id: ids[5]
    parent: ids[4]
    path: "#{ids[3]}##{ids[0]}##{ids[1]}##{ids[4]}##{ids[5]}"
    name: 'Misha'
    surname: 'Mihailov'
    lastname: 'Mihailovich'
    login: 'misha'
    email: 'stepan@cyka.com'
    password: '123123123'
    passConfirm: '123123123'
    isMain: false
    balance: 0

  forRegTest:
    _id: ids[2]
    email: 'stepan@example.com'
    login: 'sosloow'
    name: 'Stepan'
    surname: 'Shilin'
    lastname: 'Vladimirovich'
    password: 'lojkadegtya'
    passConfirm: 'lojkadegtya'
    isMain: false
    balance: 0

  mlm:
    _id: ids[3]
    parent: null
    path: ids[3].toString()
    email: 'mlm@example.com'
    login: 'mlmmlm'
    name: 'mlm'
    surname: 'mlm'
    lastname: 'mlm'
    password: 'mlm12345'
    passConfirm: 'mlm12345'
    isMain: true
    balance: 0
