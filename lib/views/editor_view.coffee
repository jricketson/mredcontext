Haml = require('haml')
mixin = require('../mixin')
movable = require('./mixins/movable')

class EditorView extends Backbone.View
  className: 'editor'

  template: Haml """
    .titleBar.moveHandle
      .filename= model.projectPath()
    .codeEditor
    .resizer
    .closer
  """

  events:
    'mousedown .resizer': '_startResizing'
    'mousedown': '_mousedown'
    'click': '_bringToFront'
    'click .closer': '_close'

  initialize: (options) ->
    @model.on('reloaded', @_setFileContent)
    @model.on('change:fileType', => 
      @codeEditor.setOption('mode', @model.get('fileType')) if @codeEditor?
    )
    @position = options.position
    @_initialLine = options.line

  toJSON: ->
    path: @model.get('path')
    position:
      top: @$el.position().top
      left: @$el.position().left
      width: @$el.width()
      height: @$el.height()
    line: @_scrollLine()

  getSelection: -> @codeEditor.getSelection()
  save: -> @model.writeContentsToDisk()
  _close: -> @trigger('close')
  _bringToFront: -> @trigger('focussed')
    
  _mousedown: (e)->
    @_startMoving(e)
    @_bringToFront(e)

  _setFileContent: =>
    return unless @model.loaded()
    @_listenToCodeEditorChanges = false
    @codeEditor.setValue(@model.get('content'))
    @_listenToCodeEditorChanges = true
    return unless @_initialLine
    setTimeout((=> @_scrollToLine(@_initialLine)), 100 )

  render: ->
    @$el.html(@template(model:@model))
    @$el.css(
      top: @position?.top || 100
      left: @position?.left || 100
      width: @position?.width || 500
      height: @position?.height || 300
    )
    @codeEditor = CodeMirror(@$el.find('.codeEditor')[0], 
      mode:  @model.get('fileType')
      lineWrapping: false
      autoClearEmptyLines: true
      lineNumbers: true
      onChange: => 
        if @_listenToCodeEditorChanges
          @model.set(content: @codeEditor.getValue())
    )
    @_setFileContent()
    setTimeout(=>
      @setHeightAndWidth(
        @position?.height || 300
        @position?.width || 500
      )
    , 10)    
    @

  _scrollLine: ->
    @codeEditor.coordsChar(@codeEditor.getScrollInfo()).line

  _scrollToLine: (line) ->
    coords = @codeEditor.charCoords({line:line,ch:0}, 'local')
    @codeEditor.scrollTo(0, coords.y)

  setHeightAndWidth: (height, width) ->
    hDiff = height - @$el.height()
    wDiff = width - @$el.width()
    edWidth = @$el.find('.codeEditor').width()
    edHeight= @$el.find('.codeEditor').height()
    @$el.height(height)
    @$el.width(width)
    @codeEditor.setSize(
        width
        height
    )
    @codeEditor.refresh()

  _startResizing: (e) ->
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

mixin.include(EditorView, movable)
exports.EditorView = EditorView
