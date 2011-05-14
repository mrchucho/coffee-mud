Logic = require './logic'

class LockedDoor extends Logic
  constructor: ->
    @constraints =
      'can enter portal': (who, what) =>
        @inform who, "#{what} is locked"
        false


exports.LockedDoor = LockedDoor
