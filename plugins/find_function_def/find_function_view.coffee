Haml = require('haml')
events = require('events')
mixin = require("#{process.cwd()}/lib/mixin")
selectable = require("#{process.cwd()}/lib/views/mixins/selectable")
fileList = require("#{process.cwd()}/lib/models/file_list").fileList
editorPane = require("#{process.cwd()}/lib/views/editor_pane_view").editorPane
configuration = require("#{process.cwd()}/lib/configuration").configuration
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
    "click .results .item": "_selectItem"
    "keyup" : "_onkeypressed"

  initialize: ->
    @_searcher = new searcher.Searcher(@_state)

  render: ->
    @$el.html(@template())
    @$el.attr('tabindex', '1')
    @

  hide: ->
    @$el.hide()
    @_searcher.cancel
    @

  search: ->
    @selectableReset()
    @_searcher.search(@_getSelection()).progress(
      (file, lineNumber, line) =>
        @$el.find(".results").append(@matchtemplate('match':file, lineNumber:lineNumber, line: line))
    ).fail(
      (err) ->  # tell the user
    )
    @$el.show().focus()
    @

  _getSelection: -> editorPane().getSelection()

  _resultSelected: (result) ->
    @_searcher.resetSearch()
    editorPane().showEditorForFile(@model.getByPath(result.data('path')), line: result.data('linenumber'))
    @hide()

mixin.include(FindFunctionView, selectable)
exports.register = ->
  view = new FindFunctionView(model:fileList())
  $("body").append view.render().el
  $(document).bind('keyup', 'ctrl+/', -> view.search())
