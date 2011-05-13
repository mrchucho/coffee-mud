Game = require('./game').Game
EventEmitter = require('events').EventEmitter

class Reporter extends EventEmitter # extends "Logic" # ... actually just imitates Logic...
  constructor: (@player, @client) ->
    @on('announce', (event) -> @client.display(event.msg))
    @on('say', (event) -> @say(event.performer, event.msg))
    @on('see', (event) -> @see(event.target))
    @on('vision', (event) -> @client.display(event.sight.replace(@player.name, 'You')))
    @on('leave', (event) -> @client.remove_handler())
    @on('leave realm', (event) -> @client.display("#{event.performer} has left the realm"))
    @on('enter realm', (event) -> @client.display("#{event.performer} has entered the realm"))
    @on('enter room', (event) -> @enterRoom(event.performer, event.portal))
    @on('leave room', (event) -> @leaveRoom(event.performer, event.portal))

  see: (what) ->
    # room vs realm vs player vs item ...
    @client.display("You see #{what.name || what.description}.")
    @client.display("It is a #{what.size} room.") if what.size?
    occupants = (player.name for player in what.players) if what.players?
    if occupants?.length > 0
      @client.display("#{occupants.join(', ')} #{if occupants.length == 1 then "is" else "are"} here.")
    exits = (portal.description for portal in what.portals) if what.portals?
    if exits?.length > 0
      @client.display("You see the following exits: #{exits.join(', ')}")

  say: (who, says) ->
    speaker = if who == @player then "You say" else "#{who.name} says"
    @client.display("#{speaker} \"#{says}\"")

  enterRoom: (player, portal) ->
    if player == @player
      Game.emit('attempt look', @player)
    else
      @client.display(
        if portal? then "#{player} enters from #{portal}" else "#{player} appears from nowhere"
      )

  leaveRoom: (player, portal) ->
    return if player == @player
    @client.display(
      if portal? then "#{player} leaves through #{portal}" else "#{player} vanishes..."
    )


module.exports = Reporter
