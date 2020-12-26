Work = require('mongoose').model 'Work'
Resource = require('../../services/resource')
works = new Resource('Work', recyclable: true, fileAttached: 'photo')

works.router.post '/:id/photo', (req, res) ->
  Work.findById(req.params.id).exec (err, work) ->
    work.attach 'photo', req.files.file, (err) ->
      return res.status(400).json(err) if err

      work.save (err, work) ->
        return res.status(400).json err if err

        res.json work

works.router.delete '/:id/photo', (req, res) ->
  Work.findById(req.params.id).exec (err, work) ->
    return res.status(400).json(err) if err

    work.photo = null
    work.save (err, work) ->
      return res.status(400).json err if err

      res.json work

works.mount()

module.exports = works
