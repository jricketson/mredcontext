editor = require('./editor_view') 
Backbone = require('backbone')
_ = require('underscore')

class EditorPaneView extends Backbone.View

  id: "editorPane"

  events: 
    'mousedown': '_startScrolling'
    'mouseup': '_stopScrolling'

  initialize: ->
    @_editors = []

  showEditorForFile: (file, options={}) ->
    file.loadFromDiskIfNeeded()
    newEd = @_newEditor(file, options)
    @$el.append newEd.el
    setTimeout((-> newEd.$el.click()),10) #to give focus, so that it moves to front

  saveActive: -> @activeEditor().save()
  activeEditor: -> _.last(@_editors)
  getSelection: -> @activeEditor().getSelection()

  _newEditor: (file, options) ->
    newEd = new editor.EditorView($.extend({model:file}, options)).render()
    newEd.on('moved resized', => @_updateLayout())
    newEd.on('focussed', => 
      @_popEditor(newEd)
      @_editors.push(newEd)
      @_sendEditorsToBack()
    )
    newEd.on('close', => @_remove(newEd))
    @_editors.push newEd
    newEd.$el.css('z-index': @_editors.length * 20)
    @_updateLayout()
    newEd

  _remove: (ed) ->
    ed.$el.remove()
    @_popEditor(ed)
    @_updateLayout()

  _popEditor: (ed) ->
    index = @_editors.indexOf(ed)
    @_editors.splice(index, 1)

  _sendEditorsToBack: ->
    for e, i in @_editors
      e.$el.css('z-index': i * 20)

  _updateLayout: ->
    layout = (e.toJSON() for e in @_editors)
    @trigger('layoutUpdated', layout)

  _startScrolling: (e) ->
    return unless e.target == @el
    @_scroller = new Scroller(this, e.clientX, e.clientY)
    @$el.on('mousemove', (e) => @_scroller.mousemove(e) )
    @$el.css('cursor': 'move')
    false

  _stopScrolling: (e) ->
    return unless e.target == @el
    @$el.off('mousemove')
    @$el.css('cursor': 'default')
    false

class Scroller

  constructor: (@pane, @startX, @startY) ->

  mousemove: (e) ->
    for editor, i in @pane._editors
      position = editor.getPosition()
      position.top += (e.clientY - @startY)
      position.left += (e.clientX - @startX)
      editor.setPosition(position)
    @startX = e.clientX
    @startY = e.clientY

exports.editorPane = -> 
  unless _instances._editor_pane?
    _instances._editor_pane = new EditorPaneView()
    $('#pageWrapper').append(_instances._editor_pane.el)
  _instances._editor_pane 