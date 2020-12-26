users = [{
    _id: '5'
    networth: 60
    ownNetworth: 60
    path: '1#2#3#4#5'
    qualification:
      bonus: 20
    children: []
  }, {
    _id: '4'
    networth: 70
    ownNetworth: 10
    path: '1#2#3#4'
    qualification:
      bonus: 0
  }, {
    _id: '3'
    networth: 150
    ownNetworth: 80
    path: '1#2#3'
    qualification:
      bonus: 10
  }, {
    _id: '2'
    networth: 300
    ownNetworth: 150
    path: '1#2'
    qualification:
      bonus: 0
  }, {
    _id: '1'
    ownNetworth: 700
    networth: 1000
    path: '1'
    qualification:
      bonus: 20
  }]

users[4].children = [users[3]]
users[3].children = [users[2]]
users[2].children = [users[1]]
users[1].children = [users[0]]

module.exports = users
