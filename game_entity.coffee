EventEmitter = require('events').EventEmitter

class GameEntity extends EventEmitter
  constructor: ->
    @logic = []
    @on('action', (args) ->
      console.log("[#{@name || @description}] is handling [#{args.action}]")
      logic.emit(args.action, args) for logic in @logic
    )

module.exports = GameEntity
