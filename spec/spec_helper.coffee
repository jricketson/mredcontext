Backbone = require('backbone')

global.document= 
  createElement: ->

global._instances={}

global.$ = -> 
  for k, v of $.fn
    @[k] = v
  this

$.fn = 
  bind: ->
  attr: ->

Backbone.setDomLibrary($)

console.logdir = (thing) ->
  console.log("DIR: ", Object.keys(thing).join(', '))
  console.log("TOSTRING: ", thing.toString())
