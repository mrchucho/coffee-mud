EventEmitter = require('events').EventEmitter
Room = require('./room')

class Game extends EventEmitter
  constructor: ->
    @players = {}
    @rooms   = []
    @commands = # [callback, usage, description]
      help:  [@help,  'help', 'Get a list of commands']
      look:  [@look,  'look [object]', 'Look at the room(default) or at an object within the room']
      say:   [@say,   'say <phrase>', 'Speak']
      quit:  [@quit,  'quit', 'Quit the Game']
      emote: [@emote, 'emote <verb phrase>', 'Perform a superfluous action']

# -----------------------------------------------------------------------------
# Commands
# -----------------------------------------------------------------------------
  help: (player, args...)->
    cmd = game.commands[args[0]]
    msg = 
      if cmd?
        "    #{cmd[1]} - #{cmd[2]}"
      else
        help_msg = for c, u of game.commands
          "    #{u[1]} - #{u[2]}"
        "The following commands are available:\n#{help_msg.join('\n')}"

    player.emit('action', {action: 'announce', performer:player, msg: msg})

  look: (player, args...) ->
    game.emit('attempt look', player, {target: args.join(' ')})

  say: (player, args...) ->
    game.emit('attempt say', player, {msg: args.join(' ')})

  quit: (player) ->
    player.emit('action', {action: 'leave', performer: player})

  emote: (player, args...) ->
    game.emit('vision', player.room, {sight: "#{player} #{args.join(' ')}"})


# -----------------------------------------------------------------------------
# Game Utility Methods
# -----------------------------------------------------------------------------
  createRoom: (desc, f) ->
    room = new Room(desc)
    @rooms.push room
    f room

  allPlayers: (opts..., f) ->
    if opts.except?
      f(p) for own n, p of game.players when p isnt opts.except
    else
      f(p) for own n, p of game.players


# The Game!
game = new Game

# -----------------------------------------------------------------------------
# Game Engine Functionality
# -----------------------------------------------------------------------------
game.on('command', (player, args) ->
  console.log("[#{player.name}] does [#{args.data.trim()}]")
  [cmd, args...] = args.data.trim().split(' ')
  cmd =
    if cmd.match(/^'/) then "say"
    else if cmd.match(/^me/) then "emote"
    else cmd
  game.commands[cmd]?[0]?(player, args...)
)
game.on('attempt say', (speaker, args) ->
  # do stuff...
  game.allPlayers((player) ->
    player.emit('action', {action: 'say', performer:speaker, msg: args.msg})
  )
)
game.on('attempt look', (looker, args) ->
  target = game.players[args.target] || game.rooms[0]
  if target?
    looker.emit('action', {action: 'see', target: target})
    target.emit('action', {action: 'announce', msg: "#{looker.name} looks at you."})
  else
    looker.emit('action', {action: 'announce', msg: "You don't see #{args.target} here."})
)
game.on('enter realm', (player) ->
  console.log("Player #{player.name} entered the game")
  room = game.rooms[0]
  room.players.push player
  player.room = room
  game.players[player.name] = player
  game.allPlayers({except: player}, (p) ->
    p.emit('action', {action: 'enter realm', performer: player})
  )
)
game.on('leave realm', (player) ->
  console.log("Player #{player.name} left the game")
  game.allPlayers({except: player}, (p) ->
    p.emit('action', {action: 'leave realm', performer: player})
  )
  # FIXME
  for room in game.rooms
    room.players.splice(room.players.indexOf(player), 1)
  delete game.players[player.name]
)
game.on('vision', (where, args) ->
  for player in where.players
    player.emit('action', {action: 'vision', sight: args.sight})
)

(exports ? this).Game = game
