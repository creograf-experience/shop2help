module.exports = ($filter, ngTableParams) ->
  (data, filter, options) ->
    options ?= {}

    tableParams = new ngTableParams {
      page: 1
      count: 10
      sorting: options.sorting
    },
      total: data.length
      getData: ($defer, params) ->
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

        $defer.resolve(orderedData.slice((params.page() - 1) *
          params.count(), params.page() * params.count()))
