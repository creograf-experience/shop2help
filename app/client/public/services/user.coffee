angular.module('MLMApp.services.user', [])
.service 'User', ($resource, Upload) ->
  res = $resource '/api/users/:userId', {slug: '@slug'},
    query:
      method: 'POST'
      isArray: true

    addCharity:
      method: 'POST'
      url: '/api/users/charity'

    deleteCharity:
      url: '/api/users/charity'
      method: 'DELETE'

    getUserCharity:
      url: '/api/users/getusercharity/:charityId'
      isArray: true

    verifyUser:
      url: '/api/auth/verifycode/:userId'

    getReferers:
      url: '/api/users/:userId/referers'
      params:
        direct: true

    addLikeShop:
      url: '/api/users/likeshop'
      method: 'POST'

    deleteLikeShop:
      url: '/api/users/likeshop'
      method: 'DELETE'

    getLikedShops:
      url: '/api/users/getlikedshops/:userId'
      isArray: true
    
    getStructure:
      url: '/api/structure/:userId'

    update:
      url: '/api/auth/userinfo'
      method: 'PUT'
      headers:
        'Content-Type': undefined
      transformRequest: (data) ->
        return data unless data

        fd = new FormData()

        angular.forEach data, (value, key) ->
          fd.append(key, value)

        return fd

    changePass:
      method: 'PUT'
      url: '/api/auth/changepass'
    changePin:
      method: 'PUT'
      url: '/api/auth/changepin'

    login:
      method: 'POST'
      url: '/api/auth/login'
    logout:
      method: 'POST'
      url: '/api/auth/logout'
    register:
      method: 'POST'
      url: '/api/auth/register'
    getSession:
      url: '/api/auth/userinfo'
    prepareReset:
      method: 'POST'
      url: '/api/auth/preparereset'
    resetPass:
      method: 'POST'
      url: '/api/auth/resetpass'
    verify:
      method: 'POST'
      url: '/api/auth/verify'


  res.uploadPhoto = (user, file) ->
    Upload.upload
      url: "/api/users/#{user.slug}/photo"
      file: file

  return res

module.exports = 'MLMApp.services.user'
