cmsRouter = require('express').Router()
cmsRouter.use require('./login').router

# api/*
cmsRouter.use '/cms/api/pages', require('./pages').router
cmsRouter.use '/cms/api/menu', require('./menu').router
cmsRouter.use '/cms/api/news', require('./news').router
cmsRouter.use '/cms/api/leads', require('./leads').router
cmsRouter.use '/cms/api/statuses', require('./statuses').router

cmsRouter.use '/cms/api/admins', require('./admins').router
cmsRouter.post '/cms/api/changepass', require('./admins').changepass
cmsRouter.get '/cms/api/admin', require('./admins').getAdmin

cmsRouter.use '/cms/api/groups', require('./groups').router
cmsRouter.use '/cms/api/templates', require('./templates').router
cmsRouter.use '/cms/api/files', require('./file-manager').router

cmsRouter.use '/cms/api/settings', require('./settings').router
cmsRouter.post '/cms/api/mail', require('./settings').mailTest

cmsRouter.use '/cms/api/forms', require('./forms').router
cmsRouter.use '/cms/api/feedbacks', require('./feedback').router
cmsRouter.use '/cms/api/users', require('./users').router
cmsRouter.use '/cms/api/orders', require('./orders').router
cmsRouter.use '/cms/api/payments', require('./payments').router
cmsRouter.use '/cms/api/products', require('./products').router
cmsRouter.use '/cms/api/categories', require('./categories').router
cmsRouter.use '/cms/api/productproperties', require('./product-properties').router
cmsRouter.use '/cms/api/works', require('./works').router
cmsRouter.use '/cms/api/stats', require('./stats').router
cmsRouter.use '/cms/api/shops', require('./shops').router
cmsRouter.use '/cms/api/admitad', require('./admitad').router
cmsRouter.use '/cms/api/callbacks', require('./callbacks').router
cmsRouter.use '/cms/api/promo', require('./promo').router
cmsRouter.use '/cms/api/transfer', require('./transfer').router

cmsRouter.use '/cms/api/charity', require('./charity').router



cmsRouter.use '/cms/api*', (req, res) ->
  res.status(404).end()

# index.jade loads the angular app
cmsRouter.get '/cms/*', (req, res, next) ->
  res.render 'cms/index'

module.exports = cmsRouter
