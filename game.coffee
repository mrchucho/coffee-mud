events = require('events')

class Game extends events.EventEmitter
  constructor: ->
    @players = {}
    @rooms   = []
    @commands = {
      'help': @help,
      'look': @look,
      'say':  @say,
      'quit': @quit,
    }

  help: (player, args...)->
    help_msg = for cmd, f of game.commands
      cmd
    player.emit('action', {
      action: 'announce',
      performer:player,
      msg: "The following commands are available: #{help_msg.join(', ')}"
    })

  look: (player, args...) ->
    game.emit('attemptlook', player, {target: args.join(' ')})

  say: (player, args...) ->
    game.emit('attemptsay', player, {msg: args.join(' ')})

  quit: (player) ->
    player.emit('action', {action: 'leave', performer: player})

game = new Game

game.on('command', (player, args) ->
  console.log("Player #{player.name} does [#{args['data'].trim()}]")
  [cmd, args...] = args['data'].trim().split(' ')
  game.commands[cmd]?(player, args...)
)
game.on('attemptsay', (speaker, args) ->
  console.log("#{speaker.name} said \"#{args['msg']}\"")
  # do stuff...
  for own name, player of game.players
    player.emit('action', {action: 'say', performer:speaker, msg: args['msg']})
)
game.on('attemptlook', (looker, args) ->
  target = t for t in game.players when t.name == args['target'] # || looker.room
  if target?
    looker.emit('action', {action: 'see', target: target})
    target.emit('action', {action: 'announce', msg: "#{looker.name} looks at you."})
  else
    looker.emit('action', {action: 'announce', msg: "You don't see #{args['target']} here."})
)
game.on('enterrealm', (player) ->
  console.log("Player #{player.name} entered the game")
  game.players[player.name] = player
)
game.on('leaverealm', (player) ->
  console.log("Player #{player.name} left the game")
  delete game.players[player.name]
)

(exports ? this).Game = game
