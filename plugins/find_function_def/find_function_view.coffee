Haml = require('haml')
events = require('events')
mixin = require('../../lib/mixin')
fileList = require('../../lib/models/file_list').fileList
editorPane = require('../../lib/views/editor_pane_view').editorPane
configuration = require('../../lib/configuration').configuration
searcher = require('./searcher')
Backbone = require ('backbone')

class FindFunctionView extends Backbone.View
  id: "findFunction"

  template: Haml """
  .results
  """
  matchtemplate: Haml """
  .item(data-path=match.get('path') data-linenumber=lineNumber)
    .item_inner
      .title
        %span.name= match.name()
         
        %span.lineNumber
           (line: 
          = lineNumber
          )
      .line= line
  """

  events:
    "click .results .item": "_selectFile"
    "keyup" : "_onkeypressed"

  initialize: ->
    @_searcher = new searcher.Searcher(@_state)

  render: ->
    @$el.html(@template())
    @$el.attr('tabindex', '1')
    @

  hide: ->
    @_removeResults()
    @$el.hide()
    @_searcher.cancel
    @

  search: ->
    @_searcher.search(@_getSelection()).progress(
      (file, lineNumber, line) =>
        @$el.find(".results").append(@matchtemplate('match':file, lineNumber:lineNumber, line: line))
    ).fail(
      (err) ->  # tell the user
    )
    @$el.show().focus()
    @_selectedIndex = -1
    @

  _selectFile: (e) -> @_resultSelected($(e.currentTarget))
  _getSelection: -> editorPane().getSelection()
  _removeResults: -> @$el.find(".results").empty()

  _onkeypressed: (e) -> 
    switch $.hotkeys.specialKeys[e.which]
      when "up" then @_goUp(e)
      when "down" then @_goDown(e)
      when "return" then @_chooseSelection()
      when "esc" then @hide()

  _resultSelected: (result) ->
    @_searcher.resetSearch()
    editorPane().showEditorForFile(@model.getByPath(result.data('path')), line: result.data('linenumber'))
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

exports.register = ->
  view = new FindFunctionView(model:fileList())
  $("body").append view.render().el
  $(document).bind('keyup', 'ctrl+/', -> view.search())
