Logic = require('./logic')
{after, every, rand} = require('../../utils')

class Wandering extends Logic
  constructor: (@gameEntity, @interval = 10000) ->
    every @interval, () => @wander()

  wander: ->
    exit = @gameEntity.room.portals[rand(0, @gameEntity.room.portals.length - 1)]
    Game = require('../../game').Game
    Game.emit('attempt enter portal', @gameEntity, {room: exit.end, portal: exit})


exports.Wandering = Wandering
