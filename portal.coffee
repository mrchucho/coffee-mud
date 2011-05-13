GameEntity = require('./game_entity')

class Portal extends GameEntity
  constructor: (@description) ->
    @start = null
    @end   = null

  toString: -> @description


module.exports = Portal


