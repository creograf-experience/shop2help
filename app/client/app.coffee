angular.module('VitalCms', [
  'ui.router'
  'ui.bootstrap'
  'ui.tinymce'
  'ui.sortable'
  'ngAnimate'
  'ngTable'
  'ngTableExport'
  'ngImgCrop'
  'sbDateSelect'
  'ncy-angular-breadcrumb'
  'ngFileUpload'
  'VitalCms.services'
  'VitalCms.filters'
  'VitalCms.directives'
  'VitalCms.controllers'
])

.config(($urlRouterProvider, $locationProvider, $httpProvider, $breadcrumbProvider) ->
  $locationProvider.html5Mode true

  $urlRouterProvider.otherwise '/'

  authInterceptor = ($q, $rootScope) ->
    responseError: (rejection) ->
      if rejection.status == 403
        $rootScope.alerts.push
          msg: 'Нет доступа'
          type: 'danger'
      else if rejection.status == 401
        window.location = "/cms/login"
        return
      $q.reject(rejection)

  $httpProvider.interceptors.push(['$q', '$rootScope', authInterceptor])

  $breadcrumbProvider.setOptions
    templateUrl: '/cms/partials/directives/breadcrumbs.html'

  tinyMCE.baseURL = '/tinymce'
  moment.locale('ru')

).run ['$rootScope', '$location', 'AdminService',
($rootScope, $location, AdminService) ->
  AdminService.getAdminObject().success (admin) ->
    $rootScope.session = admin
]

angular.element(document).ready  ->
  angular.bootstrap document, ['VitalCms']





plural = (word, num) ->
  forms = word.split('_')
  if num % 10 == 1 and num % 100 != 11 then forms[0] else if num % 10 >= 2 and num % 10 <= 4 and (num % 100 < 10 or num % 100 >= 20) then forms[1] else forms[2]

relativeTimeWithPlural = (number, withoutSuffix, key) ->
  format =
    'mm': if withoutSuffix then 'минута_минуты_минут' else 'минуту_минуты_минут'
    'hh': 'час_часа_часов'
    'dd': 'день_дня_дней'
    'MM': 'месяц_месяца_месяцев'
    'yy': 'год_года_лет'
  if key == 'm'
    if withoutSuffix then 'минута' else 'минуту'
  else
    number + ' ' + plural(format[key], +number)

monthsCaseReplace = (m, format) ->
  months =
    'nominative': 'январь_февраль_март_апрель_май_июнь_июль_август_сентябрь_октябрь_ноябрь_декабрь'.split('_')
    'accusative': 'января_февраля_марта_апреля_мая_июня_июля_августа_сентября_октября_ноября_декабря'.split('_')
  nounCase = if /D[oD]?(\[[^\[\]]*\]|\s+)+MMMM?/.test(format) then 'accusative' else 'nominative'
  months[nounCase][m.month()]

monthsShortCaseReplace = (m, format) ->
  monthsShort =
    'nominative': 'янв_фев_март_апр_май_июнь_июль_авг_сен_окт_ноя_дек'.split('_')
    'accusative': 'янв_фев_мар_апр_мая_июня_июля_авг_сен_окт_ноя_дек'.split('_')
  nounCase = if /D[oD]?(\[[^\[\]]*\]|\s+)+MMMM?/.test(format) then 'accusative' else 'nominative'
  monthsShort[nounCase][m.month()]

weekdaysCaseReplace = (m, format) ->
  weekdays =
    'nominative': 'воскресенье_понедельник_вторник_среда_четверг_пятница_суббота'.split('_')
    'accusative': 'воскресенье_понедельник_вторник_среду_четверг_пятницу_субботу'.split('_')
  nounCase = if /\[ ?[Вв] ?(?:прошлую|следующую|эту)? ?\] ?dddd/.test(format) then 'accusative' else 'nominative'
  weekdays[nounCase][m.day()]

moment.defineLocale('ru',
  months: monthsCaseReplace
  monthsShort: monthsShortCaseReplace
  weekdays: weekdaysCaseReplace
  weekdaysShort: 'вс_пн_вт_ср_чт_пт_сб'.split('_')
  weekdaysMin: 'вс_пн_вт_ср_чт_пт_сб'.split('_')
  monthsParse: [
    /^янв/i
    /^фев/i
    /^мар/i
    /^апр/i
    /^ма[й|я]/i
    /^июн/i
    /^июл/i
    /^авг/i
    /^сен/i
    /^окт/i
    /^ноя/i
    /^дек/i
  ]
  longDateFormat:
    LT: 'HH:mm'
    LTS: 'HH:mm:ss'
    L: 'DD.MM.YYYY'
    LL: 'D MMMM YYYY г.'
    LLL: 'D MMMM YYYY г., HH:mm'
    LLLL: 'dddd, D MMMM YYYY г., HH:mm'
  calendar:
    sameDay: '[Сегодня в] LT'
    nextDay: '[Завтра в] LT'
    lastDay: '[Вчера в] LT'
    nextWeek: ->
      if @day() == 2 then '[Во] dddd [в] LT' else '[В] dddd [в] LT'
    lastWeek: (now) ->
      if now.week() != @week()
        switch @day()
          when 0
            return '[В прошлое] dddd [в] LT'
          when 1, 2, 4
            return '[В прошлый] dddd [в] LT'
          when 3, 5, 6
            return '[В прошлую] dddd [в] LT'
      else
        if @day() == 2
          return '[Во] dddd [в] LT'
        else
          return '[В] dddd [в] LT'
      return
    sameElse: 'L'
  relativeTime:
    future: 'через %s'
    past: '%s назад'
    s: 'несколько секунд'
    m: relativeTimeWithPlural
    mm: relativeTimeWithPlural
    h: 'час'
    hh: relativeTimeWithPlural
    d: 'день'
    dd: relativeTimeWithPlural
    M: 'месяц'
    MM: relativeTimeWithPlural
    y: 'год'
    yy: relativeTimeWithPlural
  meridiemParse: /ночи|утра|дня|вечера/i
  isPM: (input) ->
    /^(дня|вечера)$/.test input
  meridiem: (hour, minute, isLower) ->
    if hour < 4
      'ночи'
    else if hour < 12
      'утра'
    else if hour < 17
      'дня'
    else
      'вечера'
  ordinalParse: /\d{1,2}-(й|го|я)/
  ordinal: (number, period) ->
    switch period
      when 'M', 'd', 'DDD'
        return number + '-й'
      when 'D'
        return number + '-го'
      when 'w', 'W'
        return number + '-я'
      else
        return number
    return
  week:
    dow: 1
    doy: 7)
