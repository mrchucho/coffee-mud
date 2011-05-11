GameEntity = require('./game_entity')

class Player extends GameEntity
  constructor: (@name) ->
    @room = null
    super()

module.exports = Player
