util = require 'util'
logic = require "./lib/logic/"

exports.createLogic = (logicName, gameEntity, f) ->
  try
    newLogic = eval "new logic.#{logicName}(gameEntity)"
    f(newLogic) if f?
    newLogic
  catch error
    console.error "ERROR creating Logic \"#{logicName}\": #{error}"
