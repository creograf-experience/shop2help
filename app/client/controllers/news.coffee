start = ->
  angular.module('VitalCms.controllers.news', [])
    .config(['$stateProvider', newsConfig])
    .controller('NewsListCtrl', NewsListCtrl)
    .controller('NewsCreateCtrl', NewsCreateCtrl)
    .controller('NewsShowCtrl', NewsShowCtrl)

newsConfig = ($stateProvider) ->
  $stateProvider
    .state('news'
      url: '/news'
      templateUrl: '/cms/partials/news/index.html'
      controller: 'NewsListCtrl'
      ncyBreadcrumb:
        label: 'Новости')

    .state('newsNew'
      url: '/news/new'
      templateUrl: '/cms/partials/news/create.html'
      controller: 'NewsCreateCtrl'
      ncyBreadcrumb:
        label: 'Новая новость'
        parent: 'news')

    .state('newsShow'
      url: '/news/:newsId'
      templateUrl: '/cms/partials/news/show.html'
      controller: 'NewsShowCtrl'
      ncyBreadcrumb:
        label: '{{news.title}}'
        parent: 'news'
      resolve:
        news: ['$stateParams', 'News', ($stateParams, News) ->
          News.get(newsId: $stateParams.newsId).$promise])

class NewsListCtrl
  @$inject: ['$scope', 'News']

  constructor: ($scope, News) ->
    $scope.news = News.query()

    $scope.recycleNews = (news) ->
      index = $scope.news.indexOf(news)
      setDefaultStart() if news.isstart

      news.$recycle (index) ->
        $scope.news.splice index, 1
        $scope.alerts.push
          msg: 'Страница помещена в корзину'
          type: 'success'

    $scope.updateNews = (news) ->
      News.update newsId: news._id, news, (updated) ->
        $scope.news.__v = updated.__v

class NewsCreateCtrl
  @$inject: ['$scope', '$location', 'News']

  constructor: ($scope, $location, News) ->
    $scope.newNews = new News(visible: true, isAnnouncement: false)

    $scope.now = moment().subtract(5, 'years').format('YYYY-MM-DD')
    $scope.fiveYearsSinceNow = moment().add(5, 'years').format('YYYY-MM-DD')

    $scope.createNews = ->
      News.save $scope.newNews, ->
        $scope.newNews = {}

        $location.path('/news')

class NewsShowCtrl
  @$inject: ['$scope', 'News', 'modelOptions', '$location', 'news']

  constructor: ($scope, News, modelOptions, $location, news) ->
    $scope.initialBackup = {}

    $scope.modelOptions = modelOptions

    $scope.news = news
    $scope.News = News

    $scope.now = moment().subtract(5, 'years').format('YYYY-MM-DD')
    $scope.fiveYearsSinceNow = moment().add(5, 'years').format('YYYY-MM-DD')

    $scope.recycleNews = (i) ->
      $scope.news.$recycle (r) ->
        $scope.alerts.push
          msg: 'Страница помещена в корзину'
          type: 'success'
        $location.path('/news')

    $scope.updateNews = ->
      $scope.news.date = new Date($scope.news.date)
      News.update newsId: $scope.news._id, $scope.news, (updated) ->

        $scope.alerts.push
          msg: 'Страница успешно обновлена'
          type: 'success'

    $scope.onFileAdd = (file) ->
      News.addPhoto $scope.news._id, file

    $scope.onFileRemove = ->
      delete $scope.news.photo
      News.update {newsId: $scope.news._id}, {photo: null}

start()
