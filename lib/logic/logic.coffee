EventEmitter = require('events').EventEmitter

class Logic extends EventEmitter
  constructor: (@gameEntity) ->
    @constraints = null

  # Helpers
  inform: (recipient, about) ->
    recipient.emit('action', {action: 'announce', msg: about})


module.exports = Logic
