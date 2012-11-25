editor = require('./editor_view') 
Backbone = require('backbone')
_ = require('underscore')

class EditorPaneView extends Backbone.View

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

exports.editorPane = -> _instances._editor_pane ||= new EditorPaneView(el:$('#editorPane'))