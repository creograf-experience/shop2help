_ = require 'lodash'

describe 'career', ->
  settings = require('./fixtures/settings').settings
  Career = require('../app/services/career')(settings)
  users = require('./fixtures/career-users')

  describe 'assignQualification', ->
    it 'assigns the highest qualification possible', ->
      user =
        networth: 400
        children: [
          {networth: 220}
          {networth: 100}
          {networth: 80}
        ]

      qualifiedUser = Career.assignQualification(_.clone(user))

      expect(qualifiedUser.qualification.level).toBe 2

  describe 'qualify', ->
    qualifiedUsers = Career.qualify(users)

    it 'assigns full qualification bonus to user with no qualified children', ->
      user3 = _.find(qualifiedUsers, _id: '3')
      expect(user3.qualification.level).toBe 2
      expect(user3.bonus).toBe settings.tokenCost * 100 * user3.networth * (settings.qualifications[2].bonus / 100)

    it 'assigns partial bonus to user with qualified children', ->
      user1 = _.find(qualifiedUsers, _id: '1')
      user2 = _.find(qualifiedUsers, _id: '2')
      user3 = _.find(qualifiedUsers, _id: '3')

      expect(user1.qualification.level).toBe 3
      expect(user1.bonus).toBe (100 * settings.tokenCost * user1.networth *
        (settings.qualifications[3].bonus / 100)) -
        (100 * settings.tokenCost * user2.networth * (settings.qualifications[3].bonus / 100)) -
        (100 * settings.tokenCost * user3.networth * (settings.qualifications[2].bonus / 100))

    it 'assigns partial bonus to user with qualified children', ->
      qualifiedUsers = require('./fixtures/qualified-users')

      qualifiedUsers.forEach(Career.assignBonus)
      user1 = _.find(qualifiedUsers, _id: '1')

      expect(user1.bonus).toBe (1850000)

    it 'assigns partial bonus to user with qualified children', ->
      qualifiedUsers = require('./fixtures/qualified-users2')

      qualifiedUsers.forEach(Career.assignBonus)

      user1 = _.find(qualifiedUsers, _id: '1')
      user3 = _.find(qualifiedUsers, _id: '3')

      expect(user3.bonus).toBe 90000
      expect(user1.bonus).toBe 1790000
