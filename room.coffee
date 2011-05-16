GameEntity = require('./game_entity')
Portal = require('./portal')

class Room extends GameEntity
  constructor: (@description) ->
    @players = []
    @size = null
    @portals = []
    super()

  toString: -> @description

  exits: ->
    portal for portal in @portals when portal.start is @

  addPortal: (opts) ->
    portal = new Portal(opts.named)
    portal.start = @
    portal.end = opts.to
    @portals.push portal
    opts.to.addPortal(named: opts.named, to: @) if opts.looped?
    portal

  playerNamed: (name) ->
    return null unless name?
    (player for player in @players when player.named(name)).pop()


module.exports = Room
