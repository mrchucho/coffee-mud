exports.after = (ms, cb) -> setTimeout cb, ms
exports.every = (ms, cb) -> setInterval cb, ms
exports.rand  = (min = 0, max = 1) ->
  Math.floor(Math.random() * (max - min + 1)) + min
