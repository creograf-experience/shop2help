ProductImageCtrl = ($stateParams, product) ->
  vm = this
  index = _.findIndex product.images, (image) ->
    image._id == $stateParams.imageId

  vm.image = product.images[index]

  if index - 1 >= 0
    vm.prevImage = product.images[index - 1]
  else
    vm.prevImage = product.images[product.images.length - 1]

  if index + 1 < product.images.length
    vm.nextImage = product.images[index + 1]
  else
    vm.nextImage = product.images[0]

  return

ProductImageCtrl.$inject = ['$stateParams', 'product']

module.exports = ProductImageCtrl
