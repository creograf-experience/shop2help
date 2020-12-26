path = require 'path'
mongoose = require 'mongoose'
Schema = mongoose.Schema
slug = require 'speakingurl'
tree = require 'mongoose-path-tree'
crate = require 'mongoose-crate'
LocalFS = require 'mongoose-crate-localfs'
ImageMagick = require 'mongoose-crate-imagemagick'
async = require 'async'
_ = require 'lodash'

cache = require '../services/cache-manager'

{Mixed} = Schema.Types

CategorySchema = new Schema
  title:
    type: String
    trim: true
    default: ''
    required: true
  slug:
    type: String
    trim: true
    default: ''
  body:
    type: String
    trim: true
    default: ''
  visible:
    type: Boolean
    default: true
  seotitle:
    type: String
    trim: true
    default: ''
  seodescr:
    type: String
    trim: true
    default: ''
  seokeywords:
    type: String
    trim: true
    default: ''

CategorySchema.plugin tree

CategorySchema.plugin crate,
  storage: new LocalFS
    directory: path.resolve(__dirname, '../../public/images/categories')
    webDirectory: '/images/categories'
  fields:
    image:
      processor: new ImageMagick
        tmpDir: path.join(process.cwd(), 'tmp')
        formats: ['JPEG', 'PNG']
        transforms:
          thumb:
            resize: '200x200>'
            format: 'jpg'
          detail:
            resize: '300x300>'
          original: {}

CategorySchema.index 'parents._id': 1
CategorySchema.index 'children._id': 1

# adding slug if not presented
CategorySchema.pre 'save', (next) ->
  @slug = slug(@slug || @title)

  # short versions of categories are stored in products,
  # specifying product's cats.
  # Here we check if any of short cat's props are changed,
  # and if there are, we update corresponding products
  modified = _.intersection @modifiedPaths(), ['title', 'path', 'slug']

  return next() if @isNew || modified.length < 1

  @model('Product').update {'categories._id': @_id},
  {$set:
    'categories.$.title': @title
    'categories.$.path': @path
    'categories.$.slug': @slug},
  {multi: true}, next

CategorySchema.post 'remove', (category) ->
  mongoose.model('Product').update(
    {'categories._id': category._id},
    {$pull: categories: path: category.path})

# @param {String} slug
# @returns {Object} {
#   category: {...}
#   products: [...]
# }
CategorySchema.statics.getPopulatedCategory = (slug, next) ->
  # uh-um... REFACTOR
  pageSize = 20

  @model('Category').findOne slug: slug, (err, category) =>
    return next(err) if err || !category

    category.getChildren visible: true, 'title slug path image', (err, children) =>
      return next(err, category) if err

      category.getAncestors {}, 'title slug path', (err, parents) =>
        return next(err, category) if err

        category = _.extend(
          category.toObject(virtuals: true)
          parents: parents.reverse()
          children: children)

        next(err, category)

CategorySchema.statics.addImage = (id, file, next) ->
  @model('Category').findById(id).exec (err, category) ->
    category.attach 'image', file, (err) ->
      return next(err) if err

      category.save next

# REFACTOR move error handling somewhere
CategorySchema.statics.removeImage = (id, next) ->
  @model('Category').findById(id).exec (err, category) ->
    return next(_.extend err, status: 400) if err
    return next(message: 'not found', status: 404) unless category

    category.image = undefined

    category.save (err) ->
      return next(_.extend err, status: 400) if err
      next()

CategorySchema.statics.getCachedCategories = (next) ->
  cache.wrap "categories/#{slug}", ((cacheNext) ->
    mongoose.model('Category').find(
      visible: true
      $or: [
        {parent: null}
        {parent: $exists: false}])
    .lean()
    .exec cacheNext), next

module.exports = mongoose.model 'Category', CategorySchema
