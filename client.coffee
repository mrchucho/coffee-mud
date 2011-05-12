EventEmitter = require('events').EventEmitter

class Client extends EventEmitter
  constructor: (@conn) ->
    @handlers = []
    @on('heard', (msg) -> @conn.write msg)
    @on('end', -> @conn.end())

  display: (msg) -> @emit('heard', msg + "\n")

  prompt: (msg) -> @emit('heard', msg)

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
    if @handlers?.length isnt 0
      @handlers[@handlers.length - 1].leave()
      @handlers.pop()
      @handlers[@handlers.length - 1].enter() if @handlers.length isnt 0


module.exports = Client
