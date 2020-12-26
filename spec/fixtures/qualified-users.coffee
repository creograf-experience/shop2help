users = [{
    _id: '3'
    ownNetworth: 150
    networth: 150
    path: '1#2#3'
    qualification:
      bonus: 10
    children: []
  }, {
    _id: '2'
    ownNetworth: 250
    networth: 400
    path: '1#2'
    qualification:
      bonus: 0
  }, {
    _id: '1'
    ownNetworth: 600
    networth: 1000
    path: '1'
    qualification:
      bonus: 20
  }]

users[2].children = [users[1]]
users[1].children = [users[0]]

module.exports = users
