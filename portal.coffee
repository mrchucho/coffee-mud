GameEntity = require('./game_entity')

class Portal extends GameEntity
  constructor: (@description) ->
    @start = null
    @end   = null
    super()

  toString: -> @description


module.exports = Portal


