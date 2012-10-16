extend = (obj, mixin) ->
  for name, method of mixin
    obj[name] = method
  obj

include = (klass, mixin) ->
  extend klass.prototype, mixin

exports.extend = extend
exports.include = include