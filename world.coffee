Game  = require('./game').Game
# -----------------------------------------------------------------------------
# Create a magical world...
# -----------------------------------------------------------------------------
hall = Game.createRoom("Entrance Hall", (room) ->
  room.size = "big"
  room.addPortal(
    named: "Closet Door",
    looped: true,
    to: Game.createRoom("Closet", (room) ->
      room.addLogic "SensoryDepravationRoom"
      room.size = "tiny"
    )
  )
)

anteChamber = Game.createRoom("Antechamber", (room) ->
  room.size = "very small"
  room.addPortal(named: "Door", to: hall, looped:true)
  room.addLogic "WindyRoom"
  room.addLogic "HACKZ" # Test loading "rogue" logic
)

commonRoom = Game.createRoom("Common Room", (room) ->
  room.size = "giant"
  room.addPortal(named: "Wooden Door", to: anteChamber, looped: true)
  room.addPortal(
    named: "Trapdoor",
    to: Game.createRoom("Dungeon")
  ).addLogic "LockedDoor"
  Game.createPlayer "Pedestrian", (mob) ->
    room.addPlayer(mob).addLogic(new logic.Wandering(mob))
)

console.log("The Game now has #{Game.rooms.length} rooms:")
console.log("\t#{room.description}") for room in Game.rooms
