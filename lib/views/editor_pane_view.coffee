editor = require('./editor_view') 
overviewPane = require('./overview_pane_view') 
Backbone = require('backbone')
_ = require('underscore')
fileList = require('../models/file_list').fileList
FileModel = require('../models/file')
configuration = require('../configuration').configuration

class EditorPaneView extends Backbone.View

  id: "editorPane"

  events: 
    'mousedown': '_startScrolling'
    'mouseup': '_stopScrolling'

  initialize: ->
    @_editors = []
    @_overviewPane = new overviewPane.OverviewPaneView(editors: @_editors)

  render: ->
    @$el.append(@_overviewPane.render().el)
    this

  reloadLayout: ->
    #To reload the layout before the filelist has finished loading, 
    #the filelist needs some smarts about finding files on disk vs ones that have already been found from reloading the layout
    console.log('reloading layout')
    layout = configuration.get('layout')
    for conf in layout?.editors || []
      file = fileList().getByPath(conf.path)
      unless file?
        file = new FileModel.File(path:conf.path)
        fileList().add(file)
      @showEditorForFile(file, conf)
    @_defaultTheme = layout?.defaultTheme
    console.log('layout reloaded')

  showEditorForFile: (file, options={}) ->
    file.loadFromDiskIfNeeded()
    newEd = @_newEditor(file, options)
    @$el.append newEd.el
    setTimeout((-> newEd.$el.click()),10) #to give focus, so that it moves to front

  saveActive: -> @activeEditor().save()
  activeEditor: -> _.last(@_editors)
  getSelection: -> @activeEditor().getSelection()

  _newEditor: (file, options) ->
    newEd = new editor.EditorView($.extend({model:file, theme: @_defaultTheme}, options)).render()
    newEd.on('configUpdated', => @_updateLayout())
    newEd.on('themeUpdated', (newTheme) =>
      @_defaultTheme = newTheme
      @_updateLayout()
    )
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
    @trigger('layoutUpdated', {defaultTheme: @_defaultTheme, editors: layout})
    @_overviewPane.update()

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
    @pane._updateLayout()
    @startX = e.clientX
    @startY = e.clientY

exports.editorPane = -> 
  unless _instances._editor_pane?
    _instances._editor_pane = new EditorPaneView()
    $('#pageWrapper').append(_instances._editor_pane.render().el)
  _instances._editor_pane 