ProductProperty = require('mongoose').model 'ProductProperty'
Resource = require('../../services/resource')
productProperties = new Resource('ProductProperty')

productProperties.mount()

module.exports = productProperties
