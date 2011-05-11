GameEntity = require('./game_entity')

class Room extends GameEntity
  constructor: (@description) ->
    @players = []
    @size = null
    super()

module.exports = Room
