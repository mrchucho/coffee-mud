net = require('net')

Game = require('./game').Game
Client = require('./client')
LoginHandler = require('./handlers')
logic = require('./lib/logic/')

# -------------- MAIN ------------------
hall = Game.createRoom("Entrance Hall", (room) ->
  room.size = "big"
  room.addPortal(
    named: "Closet Door",
    looped: true,
    to: Game.createRoom("Closet", (room) ->
      room.addLogic(new logic.SensoryDepravationRoom())
      room.size = "tiny"
    )
  )
)

anteChamber = Game.createRoom("Antechamber", (room) ->
  room.size = "very small"
  room.addPortal(named: "Door", to: hall, looped:true)
  room.addLogic new logic.WindyRoom()
)

commonRoom = Game.createRoom("Common Room", (room) ->
  room.size = "giant"
  room.addPortal(named: "Wooden Door", to: anteChamber, looped: true)
  room.addPortal(
    named: "Trapdoor",
    to: Game.createRoom("Dungeon")
  ).addLogic new logic.LockedDoor()

)

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

server.listen 4000

