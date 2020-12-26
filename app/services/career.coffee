_ = require 'lodash'

qualifications = []
tokenCost = 0
emptyQualification =
  name: '0%'
  bonus: 0

assignChildren = (user, i, users) ->
  _.extend(user,
    children: users.filter (child) ->
      child.path.indexOf("#{user._id}##{child._id}") >= 0)

assignQualification = (user) ->
  qualification = _.find qualifications.slice().reverse(), qualifyLevel(user)
  _.extend(user, qualification: (qualification || emptyQualification))

assignBonus = (user) ->
  ownBonus = user.ownNetworth * (user.qualification.bonus / 100) * tokenCost

  childrenModufiers = user.children.reduce ((result, child) ->
    result.concat child.modifiers
  ), []

  bonus = childrenModufiers.reduce ((result, mod) ->
    remainBonus = Math.max(0, user.qualification.bonus - mod.bonus)

    mod.bonus = mod.bonus + remainBonus

    result + (remainBonus * mod.networth / 100 * tokenCost)
  ), ownBonus

  _.extend(user,
    modifiers: [bonus: user.qualification.bonus, networth: user.ownNetworth].concat(childrenModufiers)
    bonus: bonus)

qualifyLevel = (user) ->
  (qualification) ->
    enoughChildren = qualification.balance.length <= user.children.length
    return false unless enoughChildren

    balancedNetworth = qualification.balance.reduce(
      balanceNetworth,
      networth: user.networth
      children: user.children).networth

    return balancedNetworth >= qualification.limit

balanceNetworth = (result, limit) ->
  richiestChild = _.max(result.children, 'networth')
  modifier = richiestChild.networth - Math.min(richiestChild.networth, limit)

  networth: result.networth - modifier
  children: _.without result.children, richiestChild

normalizeQualifications = (qualifs) ->
  qualifs.map (qualif, i) ->
    limit: +qualif.limit || Infinity
    balance: qualif.balance.map((n) -> +n || 0)
    bonus: +qualif.bonus || 0
    name: qualif.name
    level: i

qualify = (users) ->
  _(users)
    .sortBy((user) -> -user.path.length)
    .each(assignChildren)
    .each(assignQualification)
    .each(assignBonus)
    .value()

module.exports = (options) ->
  qualifications = normalizeQualifications(options.qualifications)
  tokenCost = +options.tokenCost * 100

  return {
    qualify: qualify
    assignQualification: assignQualification
    assignBonus: assignBonus
  }
