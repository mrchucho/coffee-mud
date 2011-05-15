net = require('net')
Client = require('./client')
LoginHandler = require('./handlers')

console.log("The Game now has #{Game.rooms.length} rooms:")
console.log("\t#{room.description} - #{room.size}") for room in Game.rooms

server = net.createServer((stream) ->
  stream.setEncoding 'utf8'
  client = new Client(stream)

  stream.on('connect', ->
    client.switchHandler new LoginHandler(client)
  )

  stream.on('data', (data) ->
    client.update data
  )

  stream.on('end', ->
    client.end()
  )
)

require './world'
server.listen 4000

