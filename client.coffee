EventEmitter = require('events').EventEmitter
require('./ext')

class Client extends EventEmitter
  constructor: (@conn) ->
    @handlers = []
    @on 'heard', (msg) ->
      try
        @conn.write msg
      catch error
        console.error "[ERROR] #{error}"
    @on 'end', ->
      try
        @conn.end()
      catch error
        console.error "[ERROR] #{error}"

  display: (msg) -> @emit('heard', msg + "\n")
  prompt: (msg) -> @emit('heard', msg)

  end: ->
    @removeHandler() while @handlers.length > 0

  update: (data) ->
    @handlers.top()?.handle data

  switchHandler: (handler) ->
    @handlers.top().leave() if @handlers.length isnt 0
    @handlers.pop()
    @handlers.push(handler)
    @handlers.top().enter()

  removeHandler: ->
    if @handlers?.length isnt 0
      @handlers.top().leave()
      @handlers.pop()
      @handlers.top().enter() if @handlers.length isnt 0
    @emit('end') if @handlers.length == 0


module.exports = Client
