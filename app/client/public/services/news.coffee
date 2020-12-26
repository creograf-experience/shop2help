module.exports = ($resource) ->
  $resource '/api/news/:slug', {},
    getNews:
      params:
        isAnnouncement: false
      isArray: true
    getAnnouncements:
      params:
        isAnnouncement: true
      isArray: true
