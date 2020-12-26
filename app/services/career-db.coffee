mongoose = require 'mongoose'
moment = require 'moment'
async = require 'async'
_ = require 'lodash'

{CmsModule, User, Payment} = require '../models'

checkDate = (next) -> ->
  CmsModule.findOne name: 'main', (err, cmsmodule) ->
    return next(err) if err

    unless cmsmodule && cmsmodule.settings
      return next(new Error('govno'))

    settings = cmsmodule.settings

    Career = require('./career')(
      qualifications: settings.qualifications
      tokenCost: settings.tokenCost)

    now = moment()
    nextTime = moment(settings.nextTime)
    prevTime = moment(settings.prevTime) if +settings.prevTime

    switch settings.period
      when 'week' then afterNextTime = +nextTime.clone().add(7, 'days')
      when '2weeks' then afterNextTime = +nextTime.clone().add(14, 'days')
      when 'month' then afterNextTime = +nextTime.clone().add(1, 'month')
    # switch settings.period
    #   when 'week' then prevTime = +nextTime.clone().subtract(7, 'days')
    #   when '2weeks' then prevTime = +nextTime.clone().subtract(14, 'days')
    #   when 'month' then prevTime = +nextTime.clone().subtract(1, 'month')
    #   else  prevTime = +nextTime.subtract(1, 'month')

    if now.isBefore(nextTime)
      User.findOne isMain: true, (err, mainUser) ->
        return next(err) if err || !mainUser

        query = createdAt:
          $lt: +now

        if +prevTime
          query.createdAt.$gt = +prevTime

        User.getReferers mainUser, query, (err, report) ->
          return next(err) if err

          users = Career.qualify(report.referers)
          currentDate = moment().format('DD.MM.YYYY')

          async.each users, ((user, asyncNext) ->
            User.update(
              {_id: user._id},
              {predictedQualification: user.qualification},
              asyncNext)), (err) ->
                console.log err if err
                console.log "#{currentDate} Посчитан прогноз квалификации"

      return

    CmsModule.update(
      {name: 'main'}
      {
        'settings.nextTime': +afterNextTime
        'settings.prevTime': +now
      }
      (err, n) ->
        User.findOne isMain: true, (err, mainUser) ->
          return next(err) if err || !mainUser

          query = createdAt:
            $lt: +now

          if +prevTime
            query.createdAt.$gt = +prevTime

          User.getReferers mainUser, query, (err, report) ->
            return next(err) if err

            users = Career.qualify(report.referers)
            currentDate = moment().format('DD.MM.YYYY')

            async.each users, ((user, asyncNext) ->
              User.update {_id: user._id}, {qualification: user.qualification}, (err) ->
                return asyncNext(err) if err
                return asyncNext() unless user.bonus

                Payment.create(
                  total: user.bonus
                  user: user
                  purpose: "бонус за #{user.qualification.name || user.qualification.level} квалификацию от #{currentDate}"
                  isLoading: true
                  method: 'внутренний перевод'
                  status: 'completed'
                  asyncNext)), (err) ->
                    return next(err) if err
                    next(null, new Date()))

module.exports =
  checkDate: checkDate
