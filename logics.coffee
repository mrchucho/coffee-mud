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

  see: (what) ->
    # room vs realm vs player vs item ...
    @client.display("You see #{what.name || what.description}.")
    @client.display("It is a #{what.size} room.") if what.size?
    occupants = for player in (what.players || [])
      player.name
    if occupants?.length > 0
      @client.display("#{occupants.join(', ')} #{if occupants.length == 1 then "is" else "are"} here.")

  say: (who, says) ->
    speaker = if who == @player then "You say" else "#{who.name} says"
    @client.display("#{speaker} \"#{says}\"")


module.exports = Reporter
