extend = (obj, mixin) ->
  obj[name] = method for name, method of mixin        
  obj

include = (klass, mixin) ->
  extend klass.prototype, mixin

exports.extend = extend
exports.include = include