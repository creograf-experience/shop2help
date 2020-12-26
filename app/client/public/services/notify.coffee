module.exports = ->
  alerts = []

  alerts: alerts

  info: (msg) ->
    alerts.push
      type: 'info'
      msg: msg

  error: (msg) ->
    alerts.push
      type: 'danger'
      msg: msg

  backendErrors: (data) ->
    data.messages.forEach(@error) if data.messages
    @error(data.message) if data.message
