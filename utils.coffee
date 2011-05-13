module.exports =

  Array::remove = (o) ->
    @splice(@indexOf(o), 1)

  Array::first = ->
    @[0]

  Array::top = ->
    @[@.length - 1]
