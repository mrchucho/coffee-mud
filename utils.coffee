exports.after = (ms, cb) -> setTimeout cb, ms
exports.every = (ms, cb) -> setInterval cb, ms
