net = require('net')

Game = require('./game').Game
Client = require('./client')
LoginHandler = require('./handlers')

# -------------- MAIN ------------------
hall = Game.createRoom("Entrance Hall", (room) ->
  room.size = "big"
)

anteChamber = Game.createRoom("Antechamber", (room) ->
  room.size = "very small"
  room.addPortal(named: "Door", to: hall, looped:true)
)

commonRoom = Game.createRoom("Common Room", (room) ->
  room.size = "giant"
  room.addPortal(named: "Wooden Door", to: anteChamber, looped: true)
  room.addPortal(named: "Trapdoor", to: Game.createRoom("Dungeon"))
)

console.log("The Game now has #{Game.rooms.length} rooms:")
console.log("\t#{room.description} - #{room.size}") for room in Game.rooms

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
    # FIXME clean up!
    client.end
  )
)

server.listen 4000

