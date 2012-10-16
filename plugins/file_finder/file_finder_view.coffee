Haml = require('haml')
events = require('events')
Backbone = require ('backbone')
mixin = require("#{process.cwd()}/lib/mixin")
selectable = require("#{process.cwd()}/lib/views/mixins/selectable")
fileList = require("#{process.cwd()}/lib/models/file_list").fileList
editorPane = require("#{process.cwd()}/lib/views/editor_pane_view").editorPane
configuration = require("#{process.cwd()}/lib/configuration").configuration
searcher = require('./searcher')

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
    "keyup" : "_onkeypressed"
    "click .results .item": "_selectItem"

  initialize: ->
    @_state = searchIndex: ';'
    @model.on('add', @_indexFile)
    @searcher = new searcher.Searcher(@_state)

  render: ->
    @$el.html(@template())
    @

  hide: ->
    @selectableReset()
    @$el.hide()
    @

  show: ->
    @$el.show()
    @$el.find("input.filename").val('').focus()
    @_selectedIndex = -1
    @

  _indexFile: (file) => @_state.searchIndex += "#{file.projectPath()};"

  _resultSelected: (result) ->
    @searcher.resetSearch()
    editorPane().showEditorForFile(@model.getByPath(result.data('path')))
    @hide()

  _filenameChanged: (e) ->
    searchString = $(e.target).val()
    return if searchString == @searcher.currentSearch()
    @selectableReset()
    return @searcher.resetSearch() if searchString == ''
    @searcher.filesMatching(searchString).progress(
      (matchPath) =>
        match=fileList().getByPath(configuration.get('rootPath')+matchPath)
        @$el.find(".results").append(@matchtemplate('match':match))
    )

mixin.include(FileFinderView, selectable)
exports.register = ->
  fileFinder = new FileFinderView(model:fileList())
  $("body").append fileFinder.render().el
  $(document).bind('keydown', 'ctrl+p', -> fileFinder.show())
