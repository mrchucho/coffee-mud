GameEntity = require('./game_entity')

class Player extends GameEntity
  constructor: (@name) ->
    @room = null
    super()

  toString: -> @name

module.exports = Player
