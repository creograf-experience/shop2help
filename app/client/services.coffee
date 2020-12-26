start = ->
  angular.module('VitalCms.services', ['ngResource'])
    .factory('Page', ['$resource', Page])
    .factory('Transfer', ['$resource', Transfer])
    .factory('News', ['$resource', News])
    .factory('Product', ['$resource', Product])
    .factory('ProductProperty', ['$resource', ProductProperty])
    .factory('Lead', ['$resource', Lead])
    .factory('Order', ['$resource', Order])
    .factory('Payment', ['$resource', Payment])
    .factory('Status', ['$resource', Status])
    .factory('Admin', ['$resource', Admin])
    .factory('Group', ['$resource', Group])
    .factory('AdminService', ['$http', AdminService])
    .factory('Template', ['$resource', Template])
    .factory('PublicFile', ['$resource', PublicFile])
    .factory('Settings', ['$resource', Settings])
    .factory('Form', ['$resource', Form])
    .factory('Feedback', ['$resource', Feedback])
    .factory('Category', ['$resource', Category])
    .factory('Work', ['$resource', Work])
    .factory('Customer', ['$resource', Customer])
    .factory('Stat', ['$resource', Stat])
    .factory('Shop', ['$resource', Shop])
    .factory('Charity', ['$resource', Charity])
    .factory('PromoCodes', ['$resource', PromoCodes])
    .factory('Callback', ['$resource', Callback])
    .factory('Backup', Backup)
    .factory('vitTableParams', ['$filter', 'NgTableParams', '$timeout', vitTableParams])
    .value('accessTypes', accessTypes)
    .value('modelOptions', modelOptions)

Page = ($resource) ->
  $resource '/cms/api/pages/:pageId', {pageId: '@_id'},

    # @returns a hierarchical object which represents
    # site's menu. Nodes are simplified Page objects
    menu:
      method: 'GET'
      url: '/cms/api/menu'

    # action which tells the server that
    # a child node was moved from one parent
    # node to another.
    # it requires json that looks like
    # {parent: _id, child: _id}
    updateMenu:
      method: 'PUT'
      url: '/cms/api/menu'

    # action for a trash module.
    # @returns all deleted pages.
    # obviously
    listDeleted:
      method: 'GET'
      url: '/cms/api/pages/'
      params: recycled: true
      isArray: true

    # update method with PUT verb
    # isn't default in ngResource
    update:
      method: 'PUT'

    # saves .autosave fields
    # and sets .modified = true
    autosave:
      method: 'PUT'
      url: '/cms/api/pages/:pageId/autosave'

    # copies .autosave fields to the root
    # and sets .modified = false
    publish:
      method: 'POST'
      url: '/cms/api/pages/:pageId/publish'

    # sets page.recycled = true
    recycle:
      method: 'PUT'
      url: '/cms/api/pages/:pageId/recycle'

    # sets page.recycled = false
    restore:
      method: 'PUT'
      url: '/cms/api/pages/:pageId/restore'

    # lists versions. They are simular to
    # Page objects
    getVersions:
      method: 'GET'
      url: '/cms/api/pages/:pageId/versions'
      isArray: true

    # returns a Page with isstart == true
    getHomePage:
      method: 'GET'
      url: '/cms/api/pages/home'

# dupe of Page
News = ($resource, $upload) ->
  News = $resource '/cms/api/news/:newsId', {newsId: '@_id'},
    listDeleted:
      method: 'GET'
      url: '/cms/api/news/'
      params: recycled: true
      isArray: true
    update:
      method: 'PUT'
    autosave:
      method: 'PUT'
      url: '/cms/api/news/:newsId/autosave'
    publish:
      method: 'POST'
      url: '/cms/api/news/:newsId/publish'
    recycle:
      method: 'PUT'
      url: '/cms/api/news/:newsId/recycle'
    restore:
      method: 'PUT'
      url: '/cms/api/news/:newsId/restore'
    getVersions:
      method: 'GET'
      url: '/cms/api/news/:newsId/versions'
      isArray: true
    removeImage:
      method: 'DELETE'
      url: '/cms/api/news/:productId/images/:imageId'
    save:
      method: 'POST'
      headers:
        'Content-Type': undefined
      transformRequest: (data) ->
        console.log data
        return data unless data

        fd = new FormData()
        angular.forEach data, (value, key) ->
          if value instanceof FileList
            if value.length == 1
              fd.append key, value[0]
            else if value instanceof Object
              fd.append key, JSON.stringify(value)
            else
              angular.forEach value, (file, index) ->
                fd.append "#{key}_#{index}", file
          else
            fd.append(key, value)
        return fd

  News.prototype.photoUrl = (style) ->
    if this.mainImage
      this.mainImage[style].url
    else
      '/resources/150x150.gif'

  News.addImage = (id, file) ->
    return unless id
    $upload.upload(
      url: "/cms/api/news/#{id}/images"
      method: 'POST'
      file: file)

  return News

Product = ($resource, $upload) ->
  Product = $resource '/cms/api/products/:productId', {productId: '@_id'},
    listDeleted:
      method: 'GET'
      url: '/cms/api/products/'
      params: recycled: true
      isArray: true
    search:
      method: 'GET'
      url: '/cms/api/products/search'
      isArray: true
    update:
      method: 'PUT'
    autosave:
      method: 'PUT'
      url: '/cms/api/products/:productId/autosave'
    publish:
      method: 'POST'
      url: '/cms/api/products/:productId/publish'
    recycle:
      method: 'PUT'
      url: '/cms/api/products/:productId/recycle'
    restore:
      method: 'PUT'
      url: '/cms/api/products/:productId/restore'
    getVersions:
      method: 'GET'
      url: '/cms/api/products/:productId/versions'
      isArray: true
    addCategory:
      method: 'POST'
      url: '/cms/api/products/:productId/categories'
    removeCategory:
      method: 'DELETE'
      url: '/cms/api/products/:productId/categories/:catId'
    addRelated:
      method: 'POST'
      url: '/cms/api/products/:productId/related'
    removeRelated:
      method: 'DELETE'
      url: '/cms/api/products/:productId/related/:relatedId'
    removeImage:
      method: 'DELETE'
      url: '/cms/api/products/:productId/images/:imageId'

  # used by vitImageManager directive
  Product.addImage = (id, file) ->
    $upload.upload(
      url: "/cms/api/products/#{id}/images"
      method: 'POST'
      file: file)

  Product.importPrices = (file) ->
    $upload.upload(
      url: "/cms/api/products/importprices"
      method: 'POST'
      file: file)

  return Product

ProductProperty = ($resource) ->
  $resource '/cms/api/productproperties/:propertyId', {propertyId: '@_id'},
    update:
      method: 'PUT'

Category = ($resource, $upload) ->
  Category = $resource '/cms/api/categories/:categoryId', {categoryId: '@_id'},
    listDeleted:
      method: 'GET'
      url: '/cms/api/categories/'
      params: recycled: true
      isArray: true
    update:
      method: 'PUT'
    recycle:
      method: 'PUT'
      url: '/cms/api/categories/:categoryId/recycle'
    restore:
      method: 'PUT'
      url: '/cms/api/categories/:categoryId/restore'
    getTree:
      method: 'GET'
      url: '/cms/api/categories/menu'
      isArray: true
    updateTree:
      method: 'PUT'
      url: '/cms/api/categories/menu'
    removeImage:
      method: 'DELETE'
      url: '/cms/api/categories/:categoryId/images'

  Category.addImage = (id, file) ->
    $upload.upload(
      url: "/cms/api/categories/#{id}/images"
      method: 'POST'
      file: file)

  return Category

Lead = ($resource) ->
  Lead = $resource '/cms/api/leads/:leadId', {leadId: '@_id'},
    update:
      method: 'PUT'

  # adds a random lead for tests (to DB)
  Lead.addRandom = (callback) ->
    newLead = new Lead()
    names = ['Василий', 'Лососина', 'Петр', 'Наталья', 'Кристина']
    name = names[Math.floor(Math.random()*names.length)]

    Lead.save name: name, callback

  return Lead

Order = ($resource) ->
  Order = $resource '/cms/api/orders/:orderId', {orderId: '@_id'},
    update:
      method: 'PUT'
    get:
      method: 'GET'
      url: '/cms/api/orders/:orderId/details'
    getList:
      method: 'GET'
      url: '/cms/api/orders/list'
      isArray: true
    getForUser:
      method: 'GET'
      url: '/cms/api/orders/listforuser/:userId'
      isArray: true

    exportFromAdmitad:
      method: 'POST'
      url: '/cms/api/admitad/synchronizeorder'

  # adds a random order for tests (to DB)
  Order.addRandom = (callback) ->
    names = ['Василий', 'Лососина', 'Петр', 'Наталья', 'Кристина']
    newOrder = new Order
      name: names[Math.floor(Math.random()*names.length)]
      phone: _.shuffle("1234567890".split()).join()
      email: 'head@ass.com'

    Order.save newOrder, (newOrder) ->
      callback(newOrder)

  return Order

Payment = ($resource) ->
  Payment = $resource '/cms/api/payments/:paymentId', {paymentId: '@_id'},
    update:
      method: 'PUT'
    getList:
      method: 'GET'
      url: '/cms/api/payments/list/:userId'
      isArray: true

  return Payment

# To update, change properties of statuses
# and then PUT changed array altogether. Same with sorting.
# To delete a status .slice() and PUT
Status = ($resource) ->
  $resource '/cms/api/statuses', {},
    get:
      method: 'GET'
      isArray: true
    update:
      method: 'PUT'
      isArray: true
    save:
      method: 'PUT'
      isArray: true

Admin = ($resource) ->
  $resource '/cms/api/admins/:adminId', {adminId: '@_id'},
    update:
      method: 'PUT'

    # Admin.changePass(newPass, oldPass)
    changePass:
      method: 'POST'
      url: '/cms/api/changepass'

Group = ($resource) ->
  $resource '/cms/api/groups/:groupId', {groupId: '@_id'},
    update:
      method: 'PUT'

# isn't used currently
AdminService = ($http) ->
  logIn: (username, password) ->
    $http.post '/cms/login', username: username, password: password
  logOut: ->
    $http.post '/cms/logout'
  getAdminObject: (next) ->
    $http.get '/cms/api/admin'

# templates for Page
Template = ($resource) ->
  $resource '/cms/api/templates'

# resource for Files module
PublicFile = ($resource) ->
  $resource '/cms/api/files/:path', {path: '@path'},
    update:
      method: 'PUT'

    # @returns array of files/dirs
    # in current dir
    get:
      isArray: true

    createDir:
      method: 'POST'

    # @returns a hierarchical object
    # which represents directory structure.
    # Does not contain files
    getDirTree:
      method: 'GET'
      url: '/cms/api/files/dirtree'

# api can only recieve requests for main module
# use only Settings.get('main'),
# Settings.update('main' {}), etc
Settings = ($resource) ->
  Settings = $resource '/cms/api/settings/:module', {module: '@name'},
    update:
      method: 'PUT'
    removeBanner:
      method: 'DELETE'
      url: '/cms/api/settings/main/images'
    removeImage:
      method: 'DELETE'
      url: '/cms/api/settings/main/slides/:imageId'
    processCareer:
      method: 'POST'
      url: '/cms/api/settings/career'

  return Settings

Transfer = ($resource) ->
  Transfer = $resource '/cms/api/transfer/', {},
    getList:
      method: 'GET'
      url: '/cms/api/transfer/list'
      isArray: true

    parseStatement: 
      method: 'POST'
      url: '/cms/api/transfer/parse-bank-statement'
      isArray: true 
      headers:
          'Content-Type': undefined
      transformRequest: (data) ->
        return data unless data

        fd = new FormData()

        angular.forEach data, (value, key) ->
          fd.append(key, value)

        return fd
      
  return Transfer

# resource for the Forms module
Form = ($resource) ->
  $resource '/cms/api/forms/:formId', {formId: '@_id'},
    listDeleted:
      method: 'GET'
      url: '/cms/api/forms/'
      params: recycled: true
      isArray: true

    update:
      method: 'PUT'

    recycle:
      method: 'PUT'
      url: '/cms/api/forms/:formId/recycle'

    restore:
      method: 'PUT'
      url: '/cms/api/forms/:formId/restore'

    # @returns array of filled forms
    getData:
      method: 'GET'
      url: '/cms/api/forms/:formId/data'
      isArray: true

    removeHome:
      method: 'POST'
      url: '/cms/api/forms/removehome'

Feedback = ($resource) ->
  Feedback = $resource '/cms/api/feedbacks/:feedbackId', {feedbackId: '@_id'},
    update:
      method: 'PUT'

  # adds method to a feedback instance.
  # @returns an URL to photo based
  # on the given style ('thumb', 'medium', etc)
  # parts of URL are hardcoded.
  # REFACTOR me plox
  Feedback.prototype.photoUrl = (style) ->
    if this.photo
      this.photo[style].url
    else
      '/resources/150x150.gif'
  return Feedback

Customer = ($resource) ->
  $resource '/cms/api/users/:customerId', {customerId: '@_id'},
    update:
      method: 'PUT'

    list:
      url: '/cms/api/users/list'
      isArray: true


Callback = ($resource) ->
  $resource '/cms/api/callbacks/:callbackId', {callbackId: '@_id'},
    getList:
      method: 'GET'
      url: '/cms/api/callbacks'
      isArray: true

PromoCodes = ($resource) ->
  $resource '/cms/api/promo/', {callbackId: '@_id'},
    synchronize:
      method: 'POST'
      url: '/cms/api/admitad/synchronizepromo'
    getList:
      method: 'GET'
      url:'/cms/api/promo/'
      isArray: true
    search:
      method: 'GET'
      url:'/cms/api/promo/search'
      isArray: true
    addPromo:
      method: 'POST'
      url: '/cms/api/promo/add'
    getPromo:
      method: 'GET'
      url:'/cms/api/promo/one/:promoId'
    savePromo:
      method: 'PUT'
      url:'/cms/api/promo/:promoId'

Shop = ($resource) ->
  $resource '/cms/api/shops/:shopId', {shopId: '@_id'},
    update:
      method: 'PUT'
      headers:
        'Content-Type': undefined
      transformRequest: (data) ->
        return data unless data

        fd = new FormData()

        angular.forEach data, (value, key) ->
          fd.append(key, value)

        return fd
    getList:
      url: '/cms/api/shops'
      isArray: true
    getNameList:
      url: '/cms/api/shops/light'
      isArray: true
    insert:
      method: 'POST'
      url: '/cms/api/shops/add'
      headers:
        'Content-Type': undefined
      transformRequest: (data) ->
        return data unless data

        fd = new FormData()

        angular.forEach data, (value, key) ->
          fd.append(key, value)
          
        return fd
    import:
      method: 'POST'
      url: '/cms/api/shops/import'
      headers:
        'Content-Type': undefined
      transformRequest: (data) ->
        return data unless data

        fd = new FormData()

        angular.forEach data, (value, key) ->
          fd.append(key, value)

        return fd
    addPromo:
      method: 'POST'
      url: '/cms/api/shops/promo'
    deletePromo:
      method: 'DELETE'
      url: '/cms/api/shops/:shopId/promo'

    addCategory:
      method: 'POST'
      url: '/cms/api/shops/category'
    deleteCategory:
      method: 'DELETE'
      url: '/cms/api/shops/:shopId/category'

Charity = ($resource) ->
  $resource '/cms/api/charity/:charityId', { charityId: '@_id' },
    update:
      method: 'PUT'
      headers:
        'Content-Type': undefined
      transformRequest: (data) ->
        return data unless data

        fd = new FormData()

        angular.forEach data, (value, key) ->
          fd.append(key, value)

        return fd
    getList:
      url: '/cms/api/charity'
      isArray: true
    insert:
      method: 'POST'
      url: '/cms/api/charity/add'
      headers:
        'Content-Type': undefined
      transformRequest: (data) ->
        return data unless data

        fd = new FormData()

        angular.forEach data, (value, key) ->
          fd.append(key, value)
          
        return fd
    delete:
      method: 'DELETE'
      url: '/cms/api/charity/:charityId'

Work = ($resource, $upload) ->
  Work = $resource '/cms/api/works/:workId', {workId: '@_id'},
    listDeleted:
      method: 'GET'
      params: recycled: true
      isArray: true
    update:
      method: 'PUT'
    removePhoto:
      method: 'DELETE'
      url: '/cms/api/works/:workId/photo'
    save:
      method: 'POST'
      headers:
        'Content-Type': undefined
      transformRequest: (data) ->
        return data unless data

        fd = new FormData()
        angular.forEach data, (value, key) ->
          if value instanceof FileList
            if value.length == 1
              fd.append key, value[0]
            else if value instanceof Object
              fd.append key, JSON.stringify(value)
            else
              angular.forEach value, (file, index) ->
                fd.append "#{key}_#{index}", file
          else
            fd.append(key, value)
        return fd

  Work.prototype.photoUrl = (style) ->
    if this.photo
      this.photo[style].url
    else
      '/resources/150x150.gif'

  Work.addPhoto = (id, file) ->
    return unless id
    $upload.upload(
      url: "/cms/api/works/#{id}/photo"
      method: 'POST'
      file: file)

  return Work

Stat = ($resource) ->
  $resource '/cms/api/stats/:type'

# wrapup for localStorage, used for saving
# form data and such
Backup = ->
  # stores json on some key
  # in localStorage.backups.
  # writes path relying on the current
  # module or url, e.g.
  # Backup.store('pages/new', formData) or
  # Backup.store("pages/#{page._id}", formData)
  store: (path, document) ->
    return if !(path && document)

    document.updatedAt = Date.now()

    if localStorage.backups
      backups = angular.fromJson(localStorage.backups)
    else
      backups = {}

    backups[path] = document
    localStorage.backups = angular.toJson(backups)

  restore: (path) ->
    if localStorage.backups
      backups = angular.fromJson(localStorage.backups)
      backup = backups[path]
      return backup

  remove: (path) ->
    if localStorage.backups
      backups = angular.fromJson(localStorage.backups)
      delete backups[path]
      localStorage.backups = angular.toJson(backups)

  # returns patched doc if backup is up to date
  patchDoc: (doc, backup) ->
    return doc unless backup
    if doc.updatedAt > backup.updatedAt
      Backup.remove("pages/#{page._id}")
    else
      Object.keys(backup)
        .filter((fieldName) -> fieldName != 'updatedAt')
        .forEach (fieldName) -> doc[fieldName] = backup[fieldName]
    return doc

# options for access select
# in the Admins/Groups module
accessTypes = [
  'Нет доступа'
  'Только просмотр'
  'Просмотр и добавление'
  'Полный доступ'
]

# ngModelOptions
# required when vitFormAutosave is used
modelOptions =
  debounce: 1000

vitTableParams = ($filter, NgTableParams, $timeout) ->
  (data, filter, options) ->
    options ?= {}

    tableParams = new NgTableParams {
      page: 1
      count: 15
      sorting: options.sorting
    },
      total: data.length
      getData: (params) ->
        $timeout ->
          Object.keys(filter).forEach (key) ->
            filter[key] ?= ''

          filteredData = $filter('filter')(data, filter)
          orderedData = if params.sorting()
            $filter('orderBy')(filteredData, params.orderBy())
          else
            filteredData

          params.total(orderedData.length)

          if orderedData.length < (params.page() - 1) * params.count()
            params.page(1)

          return orderedData.slice((params.page() - 1) *
            params.count(), params.page() * params.count())

start()
