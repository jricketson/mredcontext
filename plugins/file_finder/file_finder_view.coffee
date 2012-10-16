Haml = require('haml')
events = require('events')
mixin = require('../../lib/mixin')
fileList = require('../../lib/models/file_list').fileList
editorPane = require('../../lib/views/editor_pane_view').editorPane
configuration = require('../../lib/configuration').configuration
searcher = require('./searcher')
Backbone = require ('backbone')

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
    "keyup input" : "_onkeypressed"
    "click .results .item": "_selectFile"

  initialize: ->
    @_state = searchIndex: ';'
    @model.on('add', @_indexFile)
    @searcher = new searcher.Searcher(@_state)

  render: ->
    @$el.html(@template())
    @

  hide: ->
    @_removeResults()
    @$el.hide()

  show: ->
    @$el.show()
    @$el.find("input.filename").val('').focus()
    @_selectedIndex = -1
    @

  _indexFile: (file) => @_state.searchIndex += "#{file.projectPath()};"
  _selectFile: (e) -> @_resultSelected($(e.currentTarget))

  _onkeypressed: (e) ->
    switch $.hotkeys.specialKeys[e.which]
      when "up" then @_goUp(e)
      when "down" then @_goDown(e)
      when "return" then @_chooseSelection()
      when "esc" then @hide()
      else @_filenameChanged(e)

  _resultSelected: (result) ->
    @searcher.resetSearch()
    @emit('fileSelected', @model.getByPath(result.data('path')))
    @hide()

  _chooseSelection: (e) ->
    @_resultSelected(@$el.find('.results .item').eq(@_selectedIndex))

  _goUp: (e) ->
    @_selectedIndex-=1
    @_highlightSelection()

  _goDown: (e) ->
    @_selectedIndex+=1
    @_highlightSelection()

  _highlightSelection: ->
    @$el.find('.results .item.highlighted').removeClass('highlighted')
    return if @_selectedIndex < 0
    @$el.find('.results .item').eq(@_selectedIndex).addClass('highlighted')

  _filenameChanged: (e) ->
    searchString = $(e.target).val()
    return if searchString == @searcher.currentSearch()
    @_removeResults()
    return @searcher.resetSearch() if searchString == ''
    @searcher.filesMatching(searchString).progress(
      (matchPath) =>
        match=fileList().getByPath(configuration.get('rootPath')+matchPath)
        @$el.find(".results").append(@matchtemplate('match':match))
    )

  _removeResults: -> @$el.find(".results").empty()

mixin.include(FileFinderView, events.EventEmitter::)
exports.register = ->
  fileFinder = new FileFinderView(model:fileList())
  $("body").append fileFinder.render().el
  fileFinder.on('fileSelected', (file) -> editorPane().showEditorForFile(file))
  $(document).bind('keydown', 'ctrl+p', -> fileFinder.show())
