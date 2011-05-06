net = require('net')
events = require('events')
Game = require('./game').Game

class Reporter extends events.EventEmitter # extends "Logic" # ... actually just imitates Logic...
  constructor: (@player, @client) ->
    @on('announce', (event) -> @client.display(event['msg']))
    @on('say', (event) -> @say(event['performer'], event['msg']))
    @on('see', (event) -> @see(event['target']))
    @on('leave', (event) -> @client.remove_handler())

  see: (what) ->
    # room vs realm vs player vs item ...
    @client.display("You see #{what.name}.")

  say: (who, says) ->
    speaker = if who == @player then "You say" else "#{who.name} says"
    @client.display("#{speaker} #{says}.")


class Player extends events.EventEmitter
  constructor: (@name) ->
    @logic = []
    @on('action', (args) ->
      console.log("#{@name} is handling: #{args['action']}")
      logic.emit(args['action'], args) for logic in @logic
    )


class Handler
  enter: ->
    console.log("enter not implemented")
  leave: ->
    console.log("leave not implemented")
  handle: (data) ->
    console.log("handle not implemented")


class GameHandler extends Handler
  constructor: (@player, @client) ->

  enter: ->
    # add logic from db/template
    @player.logic.push(new Reporter(@player, @client))
    Game.emit 'enterrealm', @player

  leave: ->
    # remove logic
    Game.emit 'leaverealm', @player
    @client.display "Goodbye"
    @client.end()

  handle: (data) ->
    Game.emit 'command', @player, {data: data}


class LoginHandler extends Handler
  constructor: (@client) ->
    @state = 'init'

  handle: (data) ->
    switch @state
      when 'init'
        @client.display "Welcome"
        @client.prompt  "Please enter your name: "
        @state = 'entername'
      when 'entername'
        name = data.trim()
        if Game.players[name]?
          @client.display "That name is already taken."
          @client.prompt  "Please enter your name: "
        else
          player = new Player(name)
          # player.logic.push ... # FIXME load logics from template
          @client.switch_handler new GameHandler(player, @client)


# Effectively chuchomud's "PlayerConnection"
class Client extends events.EventEmitter
  constructor: (@conn) ->
    @handlers = []
    @on('heard', (msg) -> @conn.write msg)
    @on('end', -> @conn.end())

  display: (msg) ->
    @emit('heard', msg + "\n")

  prompt: (msg) ->
    @emit('heard', msg)

  end: ->
    # clear handlers, notify observers, etc
    @emit('end')

  update: (data) ->
    @handlers[@handlers.length - 1].handle data

  switch_handler: (handler) ->
    @handlers[@handlers.length - 1].leave() if @handlers.length isnt 0
    @handlers.pop()
    @handlers.push(handler)
    @handlers[@handlers.length - 1].enter()

  remove_handler: ->
    console.log "remove top handler"
    if @handlers?.length isnt 0
      @handlers[@handlers.length - 1].leave()
      @handlers.pop()
      @handlers[@handlers.length - 1].enter() if @handlers.length isnt 0


# -------------- MAIN ------------------
server = net.createServer((stream) ->
  stream.setEncoding 'utf8'
  client = new Client(stream)

  stream.on('connect', ->
    client.switch_handler new LoginHandler(client)
  )

  stream.on('data', (data) ->
    client.update data
  )

  stream.on('end', ->
    client.end
  )
)

server.listen 4000

