module.exports = ->
  (priceInCents) ->
    return 0.toFixed(2) unless priceInCents
    (priceInCents / 100).toFixed(2)
