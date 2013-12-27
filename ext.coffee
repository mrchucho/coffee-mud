module.exports = \

  Array::remove = (o) ->
    @splice(@indexOf(o), 1)

  Array::first = ->
    @[0]

  Array::last = ->
    @[@.length - 1]

  Array::top = ->
    @[@.length - 1]
