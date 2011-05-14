{every} = require '../../utils'
Logic = require './logic'

class WindyRoom extends Logic
  constructor: ->
    @on 'enter room', (event) ->
      @i = every 1000, () => @inform(event.performer, "The wind blows...")
    @on 'leave room', (event) -> clearInterval(@i)


exports.WindyRoom = WindyRoom
