EventEmitter = require('events').EventEmitter

class GameEntity extends EventEmitter
  constructor: ->
    @logic = []
    @on('action', (args) ->
      console.log("[#{@}] is handling [#{args.action}]")
      logic.emit(args.action, args) for logic in @logic
    )

  named: (name) ->
    name.toLowerCase() == @toString().toLowerCase()

module.exports = GameEntity
