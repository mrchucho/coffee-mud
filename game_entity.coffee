EventEmitter = require('events').EventEmitter

class GameEntity extends EventEmitter
  constructor: ->
    @logic = []
    @logicFor = {}
    @on('action', (args) ->
      console.log("[#{@}] is handling [#{args.action}]")
      logic.emit(args.action, args) for logic in @logic
    )

  named: (name) ->
    name.toLowerCase() == @toString().toLowerCase()

  # ask: (who, what) ... room.ask(speaker, 'can say')
  # can: (who, what) ... room.can(speaker, 'say')
  ask: (who, does, what) ->
    return true unless @logicFor[does]
    @logicFor[does].every (f) -> f(who, what)

  addLogic: (logic) ->
    for constraint, callback of logic.constraints
      @logicFor[constraint] ||= []
      @logicFor[constraint].push callback
    @logic.push logic


module.exports = GameEntity
