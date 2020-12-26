mongoose = require 'mongoose'
Schema = mongoose.Schema
_ = require 'lodash'
async = require 'async'
tree = require 'mongoose-path-tree'

{ObjectId} = Schema.Types
{sumOfSquares} = require('../services/model-helpers')

TokenSchema = new Schema
  user:
    _id:
      type: ObjectId
      required: true
    login: String
  isLeft:
    type: Boolean
  closeChildrenCount:
    type: Number
    default: 0
  childrenCount:
    type: Number
    default: 0
  isPaid:
    type: Boolean
    default: false
  isActive:
    type: Boolean
    default: false
  isMain:
    type: Boolean
    default: false
  createdAt:
    type: Date
    default: Date.now
  path:
    type: String
    index: true
  parent:
    type: ObjectId
    default: null
    ref: 'Token'
  number:
    type: Number
    default: 1
  pos:
    type: Number
    default: 0
  {
    toObject: virtuals: true
    toJSON: virtuals: true
  }

TokenSchema.virtual('idString').get ->
  @_id.toString()

TokenSchema.virtual('parentString').get ->
  @parent && @parent.toString()

TokenSchema.virtual('level').get ->
  return 0 unless @path

  @path.split('#').length - 1

# calc position of a node in the tree.
# equals to the position of the first node
# on the level (sumOfSquares of prev level)
# plus the position on node's own level.
# position on node's own level is a number
# up to 2^0 + 2^1 + ... + 2^l
# where l is the level of the node
TokenSchema.pre 'save', (next) ->
  return next() unless @isNew

  unless @parent
    @path = "#{@_id.toString()}/0"
    return next()

  mongoose.model('Token').findById @parent, (err, parent) =>
    return next(err) if err || !parent

    isRight = if @isLeft then 0 else 1
    @path = "#{parent.path}##{@_id}/#{isRight}"

    posInLevel = @path
      .split('#')
      .reduce ((pos, ancestor, i) =>
        return pos unless +ancestor.split('/')[1]
        pos + Math.pow(2, @level - i)), 0

    @pos = sumOfSquares(@level - 1) + posInLevel

    next()

# Find the active token of user's sponsor.
# If there's no active sponsor's token, search
# recursively for an active token of its acestors.
# If none found, return the active user's token.
# If there's no active user's token, return null
TokenSchema.statics.findActiveSponsor = (user, next) ->
  mongoose.model('Token')
  .find(
    isPaid: false
    'user._id': $in: _.dropRight user.path.split('#'))
  .exec (err, activeTokens) ->
    return next(err) if err
    return next(null, null) unless activeTokens.length > 0
    return next(null, activeTokens[0]) if activeTokens.length == 1

    activeToken = _.chain(activeTokens)
      .sortByOrder([
          ((token) ->
            user.path.indexOf(token.user._id.toString())),
          'number'], ['asc', 'desc'])
      .last()
      .value()

    next(null, activeToken)

# tries to find token to pay for.
# If there's one, check it paid,
# create a payment instance and fill user's balance
TokenSchema.statics.updateActive = (token, next) ->
  Token = mongoose.model 'Token'
  CmsModule = mongoose.model 'CmsModule'
  User = mongoose.model 'User'

  closeAncestors = _(token.path.split('#'))
    .map((ancestor) -> ancestor.split('/')[0])
    .dropRight(1)
    .takeRight(2)
    .value()

  ancientAncestors = _(token.path.split('#'))
    .map((ancestor) -> ancestor.split('/')[0])
    .dropRight(3)
    .value()

  async.waterfall [
    (asyncNext) ->
      return asyncNext(null, token) unless closeAncestors.length > 0

      Token.update(
        {isMain: false, isPaid: false, _id: $in: closeAncestors}
        {$inc: closeChildrenCount: 1}
        {multi: true}
        (err) -> asyncNext(err))

    (asyncNext) ->
      return next(null, token) unless ancientAncestors.length > 0

      Token.update(
        {isMain: false, isPaid: false, _id: $in: ancientAncestors}
        {$inc: childrenCount: 1}
        {multi: true}
        (err) -> asyncNext(err))

    (asyncNext) ->
      Token.find(
        closeChildrenCount: $gte: 6
        childrenCount: $gte: 8
        isMain: false
        isPaid: false
        asyncNext)

    (paidTokens, asyncNext) ->
      return next(null, token) if paidTokens.length == 0

      async.eachSeries(paidTokens, ((paidToken, asyncAsyncNext) ->
        User.checkoutToken paidToken, (err) ->
          return asyncAsyncNext(err) if err

          paidToken.isPaid = true

          paidToken.save asyncAsyncNext), (err) ->
            asyncNext(err, token))
  ], next

# adds a token for the given user
# tree is build top -> down, left -> right,
# with each level starting to fill only after
# the prev level is filled.
# @returns {Object} token
TokenSchema.statics.add = (user, next) ->
  Token = mongoose.model('Token')
  newToken = new Token
    user:
      _id: user._id
      login: user.login

  Token.findActiveSponsor user, (err, activeToken) ->
    return next(err) if err

    # if there's no active token of ancestors
    # and no user's active token,
    # place in into the main token's bin tree
    unless activeToken
      return newToken.save next

    # we need this request to get a number for new token
    Token.findOne('user._id': user._id).sort('-number').exec (err, lastToken) ->
      return next(err) if err

      if lastToken
        newToken.number = lastToken.number + 1

      # find all token's children
      # to find out the token's real father
      childrenRegex = new RegExp("#{activeToken._id}\/[01]#.+$")
      Token.find(path: childrenRegex).exec (err, children) ->
        return next(err) if err

        # include the top node into candidates
        # and prepare them for comparing ids
        nodes = [activeToken].concat(children).map (node) -> node.toObject()

        nodes.forEach (parent) ->
          parent.directChildren = nodes.filter((child) ->
            child.parentString == parent.idString).length

        # sort nodes by their position in the tree
        # and get fist node not filled with childrens
        newFather = _.chain(nodes)
          .sortBy('pos')
          .find((node) -> node.directChildren < 2)
          .value()

        # if one child is filled, place newToken
        # to the right, else to the left
        newToken.parent = newFather._id
        newToken.isLeft = newFather.directChildren == 0

        newToken.save (err, token) ->
          return next(err) if err

          Token.updateActive token, next

TokenSchema.statics.fill = (total, user, next) ->
  Token = mongoose.model('Token')
  CmsModule = mongoose.model('CmsModule')

  CmsModule.findOne name: 'main', (err, cmsmodule) ->
    return next(err) if err

    amount = Math.floor(total / (+cmsmodule.settings.tokenCost * 100))

    return next(null, []) unless amount > 0

    async.mapSeries([1..amount],
      (i, nextToken) -> Token.add(user, nextToken)
      (err, tokens) -> next(err, tokens))

# get tree of tokens with filled empty tokens
fillEmptyChildren = (token, parentId) ->
  depth = 5 - token.path.substring(token.path.indexOf(parentId)).split('#').length
  emptyTree = (depth) ->
    if depth <= 0
      isEmpty: true
      children: [{isEmpty: true}, {isEmpty: true}]
    else
      isEmpty: true
      children: [emptyTree(depth - 1), emptyTree(depth - 1)]

  token.children[0] ?= emptyTree(depth)
  token.children[1] ?= emptyTree(depth)

TokenSchema.statics.getChildrenTree = (id, next) ->
  regex = childrenRegex = new RegExp("#{id}\/[01]($|(#[a-f0-9]{24}\/[01]){1,4})")
  mongoose.model('Token').find path: regex, (err, tokens) ->
    return next(err) if err

    tokens = tokens.map (token) -> token.toObject()

    tokens.forEach (token) ->
      token.children = _.filter(tokens, parentString: token.idString)
      fillEmptyChildren(token, id)

    tree = _.find tokens, idString: id.toString()

    next(null, tree)

TokenSchema.statics.getNetworths = (users, query, next) ->
  mongoose.model('Token')
    .aggregate
      $match: _.extend query, 'user._id': $in: _.map(users, '_id')
    .group
      _id: '$user._id'
      count: $sum: 1
    .exec (err, tokensCounted) ->
      return next(err) if err

      users = users.map (user) ->
        ownNetworth = _.find tokensCounted, (networth) ->
          networth._id.equals(user._id)

        if ownNetworth
          ownNetworth = ownNetworth.count
        else
          ownNetworth = 0

        _.extend user.toObject(), ownNetworth: ownNetworth

      users.forEach (user) ->
        user.networth = _.chain(users)
        .filter((ref) -> ref.path.match new RegExp("#{user._id}.*"))
        .sum('ownNetworth')
        .value()

      next(null, users)

TokenSchema.methods.getAncestors = (next) ->
  token = this
  ids = token.path
    .split('#')
    .map (chunk) ->
      chunk.split('/')[0]
    .filter (id) ->
      token.idString != id

  mongoose.model('Token').find _id: $in: ids, (err, ancestors) ->
    return next(err) if err

    next(null, ancestors)

module.exports = mongoose.model 'Token', TokenSchema
