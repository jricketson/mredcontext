exports._startResizing = (e) ->
  e.stopPropagation()
  @_startPosition=
      x:e.clientX
      y:e.clientY
      width: @$el.width()
      height: @$el.height()
  $('body').css('-webkit-user-select':'none')

  mousemove = (e) => 
    @setHeightAndWidth(
        @_startPosition.height+(e.clientY-@_startPosition.y),
        @_startPosition.width+(e.clientX-@_startPosition.x)
    )
    @trigger('resized')

  mouseup = -> 
    $('body').css('-webkit-user-select':'')
    $(document).off('mousemove', mousemove)
    $(document).off('mouseup', mouseup)

  $(document).on('mousemove', mousemove)
  $(document).on('mouseup', mouseup)

