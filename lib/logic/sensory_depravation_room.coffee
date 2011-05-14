Logic = require './logic'

class SensoryDepravationRoom extends Logic
  constructor: ->
    @constraints =
      'can look': (who, what) -> false
      'can say': (who, what) -> false
    @on 'enter room', (event) =>
      @inform event.performer, "You can't see or hear anything!"


exports.SensoryDepravationRoom = SensoryDepravationRoom
