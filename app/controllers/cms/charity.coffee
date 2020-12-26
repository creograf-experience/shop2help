router = require('express').Router()
Charity = require('mongoose').model 'Charity'

router.get '/', (req, res) ->
  Charity.find {}, (err, charities) ->
    return res.status(400).end() if err
    return res.status(404).end() if !charities

    res.json charities 

router.get '/:charityId', (req, res) ->
  Charity.findOne {_id: req.params.charityId}, (err, charity) ->
    return res.status(400).end() if err
    return res.status(404).end() if !charity
    res.json charity

router.put '/:charityId', (req, res) ->
  Charity.findOne {_id: req.params.charityId}, (err, charity) ->
    { 
      name, 
      website,
      facebook,
      vk,
      email,
      description,
      INN,
      KPP,
      checkingAccount,
      correspondentAccount,
      BIK,
      bankName,
      legalAdress,
      postalAdress,
      isVisible,
      contactPhone,
      ownerFIO
    } = req.body

    charity.name = name
    charity.website = website
    charity.facebook = facebook
    charity.vk = vk
    charity.email = email
    charity.description = description
    charity.INN = INN
    charity.KPP = KPP
    charity.checkingAccount = checkingAccount
    charity.correspondentAccount = correspondentAccount
    charity.BIK = BIK
    charity.bankName = bankName
    charity.legalAdress = legalAdress
    charity.postalAdress = postalAdress
    charity.isVisible = isVisible
    charity.contactPhone = contactPhone
    charity.ownerFIO = ownerFIO

    if req.files.file?
      charity.attach 'logo', req.files.file, (err) ->
        if err
          console.error(err)
          return res.status(400).end() 

        charity.save (err) ->
          return res.status(400).json err if err
          res.end()
    else
      charity.save (err) ->
        if err
          console.error(err)
          return res.status(400).end() 

        res.end()

router.delete '/:charityId', (req, res) ->
  Charity.findOneAndRemove {'_id' : req.params.charityId}, (err) ->
    return res.status(err.status).json err if err

    res.end()

router.post '/add', (req, res) ->
  { 
    name, 
    website,
    email,
    facebook,
    vk,
    description,
    INN,
    KPP,
    checkingAccount,
    correspondentAccount,
    BIK,
    bankName,
    legalAdress,
    postalAdress,
    ownerFIO,
    contactPhone
  } = req.body

  newCharity = new Charity({
    name, 
    website,
    facebook,
    vk,
    email,
    description,
    INN,
    KPP,
    checkingAccount,
    correspondentAccount,
    BIK,
    bankName,
    legalAdress,
    postalAdress,
    ownerFIO,
    contactPhone
  })

  if req.files.file?
    newCharity.attach 'logo', req.files.file, (err) ->
      if err
        console.error(err)
        return res.status(400).end() 

      newCharity.save (err) ->
        return res.status(400).json err if err
        res.end()
  else
    newCharity.save (err) ->
      if err
        console.error(err)
        return res.status(400).end() 

      res.end()

module.exports.router = router