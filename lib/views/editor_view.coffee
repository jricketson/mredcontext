Haml = require('haml')
mixin = require('../mixin')
movable = require('./mixins/movable')
resizable = require('./mixins/resizable')
Backbone = require ('backbone')

class EditorView extends Backbone.View
  className: 'editor'

  template: Haml """
    .titleBar.moveHandle
      .filename= model.projectPath()
    .codeEditor
    .resizer
    .closer
    .statusBar
      %select.theme
        :each t in themes
          :if t == theme
            %option(selected=true)= t
          :if t != theme
            %option= t
  """

  events:
    'mousedown .resizer': '_startResizing'
    'mousedown': '_mousedown'
    'click': '_bringToFront'
    'click .closer': '_close'
    'change .theme' :'_changeTheme'

  #TODO: it would be nice to make these autoloading
  themes: [
    'ambiance',
    'ambiance-mobile',
    'blackboard',
    'cobalt',
    'eclipse',
    'elegant',
    'erlang-dark',
    'lesser-dark',
    'monokai',
    'neat',
    'night',
    'rubyblue',
    'solarized',
    'twilight',
    'vibrant-ink',
    'xq-dark'
  ]

  initialize: (options) ->
    @model.on('change:content', @_setFileContent)
    @model.on('loaded:content', @_setFileContent)
    @model.on('change:fileType', => 
      @codeEditor.setOption('mode', @model.get('fileType')) if @codeEditor?
    )
    @_initialLine = options.line
    @_listenToModelChanges = true
    @_listenToCodeEditorChanges = true
    @_theme = options.theme || 'ambiance'

  toJSON: ->
    path: @model.get('path')
    position: @getPosition()
    line: @_getCodeEditorScrollLine()
    theme: @_theme

  getPosition: ->
    top: @$el.position().top
    left: @$el.position().left
    width: @$el.width()
    height: @$el.height()

  getSelection: -> @codeEditor.getSelection()
  save: -> @model.writeContentsToDisk()
  _close: -> @trigger('close')
  _bringToFront: -> @trigger('focussed')
    
  _mousedown: (e)->
    @_startMoving(e)
    @_bringToFront(e)

  _setFileContent: =>
    return unless @_listenToModelChanges
    @_listenToCodeEditorChanges = false
    @codeEditor.setValue(@model.get('content'))
    @_listenToCodeEditorChanges = true
    return unless @options.line
    setTimeout((=> @_scrollToLine(@options.line)), 100 )

  _codeEditorHasChanged: =>
    if @_listenToCodeEditorChanges
      @_listenToModelChanges = false
      @model.set(content: @codeEditor.getValue())    
      @_listenToModelChanges = true

  setPosition: (position) ->
    @$el.css(
      top: position?.top || 100
      left: position?.left || 100
      width: position?.width || 500
      height: position?.height || 300
    )
    setTimeout(=>
      @setHeightAndWidth(
        position?.height || 300
        position?.width || 500
      )
    , 10)

  render: ->
    @$el.html(@template(model:@model, theme: @_theme, themes: @themes))
    @codeEditor = CodeMirror(@$el.find('.codeEditor')[0], 
      mode:  @model.get('fileType')
      lineWrapping: false
      autoClearEmptyLines: true
      lineNumbers: true
    )
    @codeEditor.on('change', @_codeEditorHasChanged)
    @_setEditorTheme(@_theme)
    @_setFileContent()
    @setPosition(@options.position)
    @

  _getCodeEditorScrollLine: ->
    @codeEditor.coordsChar(@codeEditor.getScrollInfo()).line

  _scrollToLine: (line) ->
    coords = @codeEditor.charCoords({line:line,ch:0}, 'local')
    @codeEditor.scrollTo(0, coords.top)

  setHeightAndWidth: (height, width) ->
    edWidth = @$el.find('.codeEditor').width()
    edHeight= @$el.find('.codeEditor').height()
    @$el.height(height)
    @$el.width(width)
    @codeEditor.setSize(
        width
        height
    )
    @codeEditor.refresh()

  _setEditorTheme: (@_theme) ->
    @_loadTheme(@_theme)
    @codeEditor.setOption('theme', @_theme)
    @trigger('configUpdated')    
    @trigger('themeUpdated', @_theme)

  _changeTheme: (e) ->
    @_setEditorTheme($(e.currentTarget).val())

  _loadTheme: (theme) ->
    #TODO: move this to somewhere it makes sense, and also make it not add things that have already been added
    url = "#{CODEMIRROR_LOCATION}/theme/#{theme}.css"
    $('head').append("<link rel='stylesheet' type='text/css' href='#{url}' />")

mixin.include(EditorView, movable)
mixin.include(EditorView, resizable)
exports.EditorView = EditorView
