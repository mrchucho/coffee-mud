GameEntity = require('./game_entity')

class Room extends GameEntity
  constructor: (@description) ->
    @players = []
    @size = null
    super()

  toString: -> @description

module.exports = Room
