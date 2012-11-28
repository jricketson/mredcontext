Backbone = require('backbone')
_ = require('underscore')

class OverviewPaneView extends Backbone.View

  id: "overviewPane"

  initialize: (options) ->
    @_editors = options.editors

  render: ->
    @$el.resize(@onresize)
    this

  onresize: =>
    @_dimensions = 
      width: @$el.width()
      height: @$el.height()

  _scaleDimensions: (dimensions) ->
    #find min(e.top), max(e.top+height)
         #min(e.left), max(e.left+width)

    #translate point by subtracting (minLeft, minTop) 
    #then scale by dividing by scaleFactor
    #this will screw ratio: TODO: make sure scale keeps ratio

    minLeft=minTop = Infinity
    maxLeft=maxTop = -Infinity
    for e in @_editors
      pos = e.getPosition()
      minLeft = pos.left if pos.left < minLeft
      minTop = pos.top if pos.top < minTop
      maxLeft = pos.left+pos.width if pos.left+pos.width > maxLeft
      maxTop = pos.top+pos.height if pos.top+pos.height > maxTop

    scaleFactor = 0.1
    {
      left: (dimensions.left - minLeft) * scaleFactor
      top: (dimensions.top - minTop) * scaleFactor
      width: dimensions.width * scaleFactor
      height: dimensions.height * scaleFactor
    }

  update: ->
    @$el.empty() #TODO: manage instead of recreating
    for e in @_editors
      $('<div></div>').appendTo(@$el).css(@_scaleDimensions(e.getPosition()))


exports.OverviewPaneView = OverviewPaneView
