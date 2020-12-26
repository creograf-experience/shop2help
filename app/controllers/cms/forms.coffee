Form = require('mongoose').model 'Form'
FormData = require('mongoose').model 'FormData'
Resource = require('../../services/resource')
forms = new Resource('Form', recyclable: true)

forms.router.post '/removehome', (req, res) ->
  Form.update({}, {homePage: false}, {multi: true}).exec (err) ->
    return res.status(400).json err if err

    res.end()

forms.router.get '/:id/data', (req, res) ->
  FormData.find(form: req.params.id).exec (err, data) ->
    return res.status(400).end() if err

    res.json data

forms.mount()

module.exports = forms
