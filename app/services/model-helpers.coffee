path = require 'path'
crypto = require 'crypto'

module.exports =
  sumOfSquares: (n) ->
    return 0 if n < 0
    Math.pow(2, n + 1) - 1

  paidTokenPos: (pos) ->
    (pos - 14) / 8

  generatePromoCode: ->
    crypto.randomBytes(6).toString('hex')

  generateOrderCode: ->
    now = new Date()
    start = new Date(now.getFullYear(), 0, 0)
    day = Math.round((now - start) / (1000 * 60 * 60 * 24))
    hash = crypto.randomBytes(2).toString('hex')
    cyrillic = 'ABCDEFGHJKLMOPQRSTUVWXYZ'
    code = String(day).concat(hash.split('').map((n) ->
      int = parseInt(n, 16)
      if int <= 9 then n else cyrillic[int])
    .join(''))
