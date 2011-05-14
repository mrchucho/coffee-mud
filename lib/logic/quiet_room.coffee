Logic = require './logic'

class QuietRoom extends Logic
  constructor: ->
    @constraints = 'can say': (who, what) -> false


exports.QuietRoom = QuietRoom
