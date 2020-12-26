angular.module('MeetMoreApp.filters', [])
.filter 'timePassed', ($filter) ->
  (dateString) ->
    return moment(dateString).fromNow()

.filter 'curr', ($filter) ->
  (input) ->
      input = parseFloat(input).toFixed(2)
      return input.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ' ')

module.exports = 'MeetMoreApp.filters'
