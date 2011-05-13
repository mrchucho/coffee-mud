Game = require('./game').Game
Player = require('./player')
Reporter = require('./logics')

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
    Game.emit 'enter realm', @player

  leave: ->
    # remove logic
    Game.emit 'leave realm', @player
    @client.display "Goodbye"

  handle: (data) ->
    Game.emit 'command', @player, {data: data}


class LoginHandler extends Handler
  constructor: (@client) ->
    @state = 'init'

  enter: -> @handle()

  handle: (data) ->
    switch @state
      when 'init'
        @client.display "Welcome"
        @client.prompt  "Please enter your name: "
        @state = 'entername'
      when 'entername'
        name = data.trim()
        if name == ""
          @client.prompt "Please enter your name: "
        else if Game.players[name]?
          @client.display "That name is already taken."
          @client.prompt  "Please enter your name: "
        else
          player = new Player(name)
          # player.logic.push ... # FIXME load logics from template
          @client.switchHandler new GameHandler(player, @client)


module.exports = LoginHandler
