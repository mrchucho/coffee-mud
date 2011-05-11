EventEmitter = require('events').EventEmitter
Room = require('./room')

class Game extends EventEmitter
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
    game.emit('attempt look', player, {target: args.join(' ')})

  say: (player, args...) ->
    game.emit('attempt say', player, {msg: args.join(' ')})

  quit: (player) ->
    player.emit('action', {action: 'leave', performer: player})

  createRoom: (desc, f) ->
    room = new Room(desc)
    @rooms.push room
    f room

game = new Game

game.on('command', (player, args) ->
  console.log("[#{player.name}] does [#{args['data'].trim()}]")
  [cmd, args...] = args['data'].trim().split(' ')
  game.commands[cmd]?(player, args...)
)
game.on('attempt say', (speaker, args) ->
  # do stuff...
  for own name, player of game.players
    player.emit('action', {action: 'say', performer:speaker, msg: args['msg']})
)
game.on('attempt look', (looker, args) ->
  target = game.players[args['target']] || game.rooms[0]
  if target?
    looker.emit('action', {action: 'see', target: target})
    target.emit('action', {action: 'announce', msg: "#{looker.name} looks at you."})
  else
    looker.emit('action', {action: 'announce', msg: "You don't see #{args['target']} here."})
)
game.on('enter realm', (player) ->
  console.log("Player #{player.name} entered the game")
  room = game.rooms[0]
  room.players.push player
  player.room = room
  game.players[player.name] = player
)
game.on('leave realm', (player) ->
  console.log("Player #{player.name} left the game")
  for own name, player of game.players
    player.emit('action', {action: 'leave realm', performer: player})
  # FIXME
  for room in game.rooms
    room.players.splice(room.players.indexOf(player), 1)
  delete game.players[player.name]
)

(exports ? this).Game = game
