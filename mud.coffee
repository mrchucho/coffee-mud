net = require('net')
Client = require('./client')
LoginHandler = require('./handlers')

server = net.createServer (stream) ->
  stream.setEncoding 'ascii'
  client = new Client(stream)
  client.switchHandler new LoginHandler(client)

# FIXME This even does not seem to trigger...
  stream.on 'connect', ->
    client.switchHandler new LoginHandler(client)

  stream.on 'data', (data) ->
    client.update data

  stream.on 'end', ->
    client.end()

require './world'
server.listen 4000

