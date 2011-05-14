modules = [
  'logic',
  'quiet_room',
  'sensory_depravation_room',
  'windy_room',
  'locked_door'
]
for module in modules
  exports[k] = v for k, v of require "./#{module}"
