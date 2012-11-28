exports._startMoving = (e) ->
  return unless e.target == @el or $(e.target).is(".moveHandle, .moveHandle *")
  e.stopPropagation()
  pos = @$el.position()
  @_startPosition={x:e.clientX, y:e.clientY, top: pos.top, left: pos.left}
  $('body').css('-webkit-user-select':'none')

  mousemove = (e) =>
    @setTopAndLeft(
        @_startPosition.top+(e.clientY-@_startPosition.y),
        @_startPosition.left+(e.clientX-@_startPosition.x)
    )
    @trigger('configUpdated')

  mouseup = -> 
    $('body').css('-webkit-user-select':'')
    $(document).off('mousemove', mousemove)
    $(document).off('mouseup', mouseup)

  $(document).on('mousemove', mousemove)
  $(document).on('mouseup', mouseup)

exports.setTopAndLeft = (top, left) ->
  @$el.css(
    top: top
    left: left
  )
