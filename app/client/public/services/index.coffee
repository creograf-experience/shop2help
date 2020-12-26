angular.module('MLMApp.services', [
  require('./truncate.js')
  require('./session.coffee')
  require('./user.coffee')
  require('./category.coffee')
  require('./product.coffee')
  require('angular-resource')])
.service('Cart', ['$resource', require('./cart.coffee')])
.service('Order', ['$resource', require('./order.coffee')])
.service('Balance', ['$resource', require('./balance.coffee')])
.service('Token', ['$resource', require('./token.coffee')])
.service('News', ['$resource', require('./news.coffee')])
.service('Page', ['$resource', require('./page.coffee')])
.service('Settings', ['$resource', require('./settings.coffee')])
.service('Lead', ['$resource', require('./lead.coffee')])
.service('Shop', ['$resource', require('./shops.coffee')])
.service('Promo', ['$resource', require('./promo-codes.coffee')])
.service('Purpose', ['$resource', require('./purpose.coffee')])
.service('Callback', ['$resource', require('./callback.coffee')])
.service('Feedback', ['$resource', require('./feedback.coffee')])
.service('Payments', ['$resource', require('./payments.coffee')])
.service('notify', require('./notify.coffee'))
.service('mlmTableParams', ['$filter', 'ngTableParams', require('./table-params.coffee')])
.service('Charity', ['$resource', require('./charity.coffee')])
.filter('price', require('./price.coffee'))
.filter('translit', require('./translit.coffee'))
.value('cities', require('./cities.coffee'))

module.exports = 'MLMApp.services'