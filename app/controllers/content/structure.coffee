
router = require('express').Router()
User = require('mongoose').model('User')
Transfer = require('mongoose').model('Transfer')

router.get '/:userId', (req, res) ->
    return res.json {} 
    # Card.findOne(owner:req.params.userId).populate('parent', null, {}).exec (err, userCard) ->
    #     return res.json {} unless userCard
    #     User.findOne _id: userCard.parent.owner, (err, userParent) ->
    #         return res.json {} unless userParent

    #         query =
    #             $or: [
    #                 { name: new RegExp(req.query.query, 'i')}
    #                 { surname: new RegExp(req.query.query, 'i')}
    #                 { lastname: new RegExp(req.query.query, 'i')}
    #                 { login: new RegExp(req.query.query, 'i')}
    #             ]

    #         Card.find(parent: userCard._id).populate('owner', null, query).exec (err, childs) ->
    #             return res.json {} unless childs

    #             response = 
    #                 card: userCard
    #                 parent: userParent
    #                 childs: []
    #                 csv: []

    #             if req.query.type == 'all'
    #                 for child in childs
    #                     response.csv.push {
    #                         login: child.owner.login, 
    #                         fio: "#{child.owner.surname} #{child.owner.name} #{child.owner.lastname}", 
    #                         turn:  child.owner.ownTurn
    #                     }

    #                 response.childs = childs
    #                 res.json response 

    #             else if req.query.type == 'not'
                    
    #                 for child in childs
    #                     if child.owner.ownTurn == 0
    #                         response.csv.push {
    #                             login: child.owner.login, 
    #                             fio: "#{child.owner.surname} #{child.owner.name} #{child.owner.lastname}", 
    #                             turn:  child.owner.ownTurn
    #                         }
    #                         response.childs.push child
                    
    #                 res.json response
    #             else
    #                 for child in childs
    #                     if child.owner.ownTurn > 0
    #                         response.csv.push {
    #                             login: child.owner.login, 
    #                             fio: "#{child.owner.surname} #{child.owner.name} #{child.owner.lastname}", 
    #                             turn:  child.owner.ownTurn
    #                         }
    #                         response.childs.push child
    #                 res.json response

module.exports = router