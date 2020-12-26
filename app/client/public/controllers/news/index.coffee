config = ($stateProvider) ->
  $stateProvider
    .state('app.news'
      url: 'news'
      abstract: true
      template: '<ui-view>')

    .state('app.announcements'
      url: 'announcements'
      abstract: true
      template: '<ui-view>')

    .state('app.news.index'
      url: ''
      templateUrl: '/partials/news/index.html'
      controller: 'NewsListCtrl as vm')

    .state('app.announcements.index'
      url: ''
      templateUrl: '/partials/news/index.html'
      controller: 'AnnouncementListCtrl as vm')

    .state('app.news.show'
      url: '/:slug'
      templateUrl: '/partials/news/show.html'
      controller: 'NewsShowCtrl as vm')

angular.module('MLMApp.controllers.news', [])
  .config(['$stateProvider', config])
  .controller('NewsListCtrl', require('./news-list.coffee'))
  .controller('NewsShowCtrl', require('./news-show.coffee'))
  .controller('AnnouncementListCtrl', require('./announcement-list.coffee'))

module.exports = 'MLMApp.controllers.news'
