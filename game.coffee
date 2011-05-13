require('./utils')
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
      go:    [@go,    'go <exit>', 'Leave the current room through <exit>']

# -----------------------------------------------------------------------------
# Commands
# -----------------------------------------------------------------------------
  help: (player, args...)->
    cmd = game.commands[args[0]]
    msg = 
      if cmd?
        "    #{cmd[1]} - #{cmd[2]}"
      else
        helpMsg = for c, u of game.commands
          "    #{u[1]} - #{u[2]}"
        "The following commands are available:\n#{helpMsg.join('\n')}"

    player.emit('action', {action: 'announce', msg: msg})

  look: (player, args...) ->
    game.emit('attempt look', player, {target: args.join(' ') if args.length > 0})

  say: (player, args...) ->
    game.emit('attempt say', player, {msg: args.join(' ')})

  quit: (player) ->
    player.emit('action', {action: 'leave', performer: player})

  emote: (player, args...) ->
    game.emit('vision', player.room, {sight: "#{player} #{args.join(' ')}"})

  go: (player, args...) ->
    room = player.room
    name = args.join(' ')
    exit = portal for portal in room.portals when portal.named?(name) and portal.start == room
    if exit?
      game.emit('attempt enter portal', player, {room: exit.end, portal: exit})
    else
      player.emit('action', {action: 'announce', msg: "You cannot go that way"})


# -----------------------------------------------------------------------------
# Game Utility Methods
# -----------------------------------------------------------------------------
  createRoom: (desc, f) ->
    room = new Room(desc)
    @rooms.push room
    f room if f?
    room

  # TODO make opts composible, e.g. except: player, in: room
  allPlayers: (args..., f) ->
    opts = args.pop()
    if opts.except?
      f(p) for own n, p of game.players when p isnt opts.except
    else if opts.in?
      f(p) for own n, p of opts.in.players
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
  game.commands[cmd]?.first()?(player, args...)
)
game.on('attempt say', (speaker, args) ->
  # do stuff...
  game.allPlayers in: speaker.room, (player) ->
    player.emit('action', {action: 'say', performer:speaker, msg: args.msg})
)
game.on('attempt look', (looker, args) ->
  target = if args?.target? then game.players[args.target] else looker.room
  if target?
    looker.emit('action', {action: 'see', target: target})
    target.emit('action', {action: 'announce', msg: "#{looker.name} looks at you."})
  else
    looker.emit('action', {action: 'announce', msg: "You don't see #{args.target} here."})
)
game.on('enter realm', (player) ->
  console.log("Player #{player.name} entered the game")
  room = game.rooms.first()
  room.players.push player
  player.room = room
  game.players[player.name] = player
  game.allPlayers except: player, (p) ->
    p.emit('action', {action: 'enter realm', performer: player})
)
game.on('leave realm', (player) ->
  console.log("Player #{player.name} left the game")
  game.allPlayers except: player, (p) ->
    p.emit('action', {action: 'leave realm', performer: player})
  # FIXME
  for room in game.rooms
    room.players.remove(player)
  delete game.players[player.name]
)
game.on('vision', (where, args) ->
  for player in where.players
    player.emit('action', {action: 'vision', sight: args.sight})
)
game.on('attempt enter portal', (player, args) ->
  # TODO query portal, room, region, etc. Can player transport?
  oldRoom = player.room
  newRoom = args.room
  portal  = args.portal

  oldRoom.players.remove(player)
  newRoom.players.push(player)
  player.room = newRoom

  game.allPlayers in: oldRoom, (p) ->
    p.emit('action', {action: 'leave room', performer: player, room: oldRoom, portal: portal})

  if portal?
    for p in [portal, player]
      p.emit('action', {action: 'enter portal', performer: player, portal: portal})

  game.allPlayers in: newRoom, (p) ->
    p.emit('action', {action: 'enter room', performer: player, room: newRoom, portal: portal})
)


(exports ? this).Game = game
