require '../models'
Page = require('mongoose').model('Page')
Products = require('mongoose').model('Product')
sm = require('sitemap')
fs = require('fs')
path = require('path')

module.exports =
  build: ->
    sitemap = sm.createSitemap
      hostname: 'http://shop2help.ru'
      cacheTime: 60 * 60 * 24

    Page.find(visible: true, recycled: false).exec (err, pages) ->
      pages.forEach (page) ->
        sitemap.add
          url: '/' + page.slug
          priority: 1

      sitemap.toXML (xml) ->
        xmlPath = path.join(process.cwd(), 'public/sitemap.xml')
        fs.writeFile xmlPath, xml, ->
          if err
            console.log err
          else
            console.log 'Saved sitemap.xml'

  startBuilder: ->
    @build()
    setInterval @build, 12 * 60 * 60 * 1000
