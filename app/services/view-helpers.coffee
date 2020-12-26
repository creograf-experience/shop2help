placeholderImage = '/resources/150x150.gif'

module.exports =
  extendedTitle: (title, siteName) ->
    return if title
      "#{title} | #{siteName}"
    else
      siteName

  hasDetails: (category) ->
    (category.image &&
      category.image.detail &&
      category.image.detail.url) ||
      (category.children && category.children.length > 1)

  safeImage: (imgObject, style) ->
    if imgObject && imgObject[style] && imgObject[style].url
      imgObject[style].url
    else
      placeholderImage

  formatPrice: (price, discount) ->
    if +discount
      price = price * ((100 - discount) / 100)
    (price / 100).toFixed(2)

  cartSubtotal: (price, amount, discount) ->
    if +discount
      price = price * ((100 - discount) / 100)

    (price * amount / 100).toFixed(2)

  isActive: (path, currentPath) ->
    if currentPath.substr(0, path.length) == path
      'active'
    else
      ''

  absolutify: (path) ->
    if path.match /^\// then path else '/' + path

  _: require 'lodash'
  doctype: 'html'
  placeholderImage: placeholderImage
  env: process.env['NODE_ENV']
