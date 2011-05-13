module.exports =

  Array::remove = (o) ->
    @splice(@indexOf(o), 1)

  Array::first = ->
    @[0]
