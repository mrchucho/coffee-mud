{every} = require '../../utils'
Logic = require './logic'

class WindyRoom extends Logic
  constructor: (@gameEntity) ->
    @occupants = []
    @on 'enter room', (event) -> @occupants.push event.performer
    @on 'leave room', (event) -> @occupants.remove event.performer
    every 8000, () =>
      @inform(o, "The wind blows...") for o in @occupants


exports.WindyRoom = WindyRoom
