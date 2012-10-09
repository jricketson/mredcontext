Haml = require('haml')
events = require('events')
mixin = require('mixin')
fileList = require('models/file_list').fileList
editorPane = require('views/editor_pane_view').editorPane

class FileFinderView extends Backbone.View
  id: "fileFinder"

  template: Haml """
  %input.filename
  .results
  """
  matchtemplate: Haml """
  .item(data-path=match.get('path'))
    .item_inner
      .name= match.name()
      .fullName= match.projectPath()
  """

  events:
    "keyup input" : "_filenameChanged"
    "click .results .item": "_selectFile"

  render: ->
    @$el.html(@template())
    @

  _selectFile: (e) ->
    @model.resetSearch()
    @emit('fileSelected', @model.getByPath($(e.currentTarget).data('path')))
    @hide()

  _filenameChanged: (e) ->
    searchString = $(e.target).val()
    if searchString == ''
      @model.resetSearch()
      return @_removeResults()
    @_removeResults()
    @model.filesMatching(searchString).progress (match) =>
      @$el.find(".results").append(@matchtemplate('match':match))

  _removeResults: ->
    @$el.find(".results").empty()

  hide: ->
    @_removeResults()
    @$el.hide()

  show: ->
    @$el.show()
    @$el.find("input.filename").val('').focus()
    @

mixin.include(FileFinderView, events.EventEmitter::)
exports.register = ->
  fileFinder = new FileFinderView(model:fileList())
  $("body").append fileFinder.render().el
  fileFinder.on('fileSelected', (file) -> editorPane().showEditorForFile(file))
  $(document).bind('keydown', 'ctrl+p', -> fileFinder.show())


