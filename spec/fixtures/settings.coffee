module.exports =
  name: 'main'
  settings:
    tokenCost: 100
    instantBonus: [10, 5, 0, 0]
    qualifications: [{
      limit: 20
      balance: [10, 6, 4]
      bonus: 4
    }, {
      limit: 70
      balance: [35, 20, 15]
      bonus: 8
    }, {
      limit: 200
      balance: [100, 60, 40]
      bonus: 13
    }, {
      limit: 400
      balance: [200, 120, 80]
      bonus: 18
    }]
