fileList = require("#{process.cwd()}/lib/models/file_list").fileList
editorPane = require("#{process.cwd()}/lib/views/editor_pane_view").editorPane

class FindFunctionDefinition
  DELAY:1

  constructor: ->
    @_resetSearch()

  search: ->
    @_resetSearch()
    @_regex = new RegExp(@_getSelection() + '\\s*[:=]\\s*\\(?.*\\)?[-=]>')
    @_search()

  cancel: -> @_resetSearch()

  _resetSearch: ->
    global.clearTimeout(@_timer) if @_timer?
    @_index = 0
    @_timer = null

  _getSelection: -> editorPane().getSelection()

  #This stops at the first match and opens it, maybe we want to show all matches incrementally?
  _search: =>
    if (f=fileList().at(@_index))?
      if f.get('fileType') == 'coffeescript'
        @_findLineMatching(f).
          done( (line) => 
            @_openFileToDefinition(f, line)
          ).
          fail(@_delaySearch)
      else
        @_delaySearch()

  _delaySearch: =>
    @_index += 1
    @_timer = setTimeout(@_search, FindFunctionDefinition.DELAY)

  _findLineMatching: (file, functionName) ->
    promise = new $.Deferred()
    file.loadFromDiskIfNeeded().done(=>
      for line, index in file.get('content').split("\n")
        return promise.resolve(index) if @_regex.test(line)
      promise.reject()
    )
    promise

  _openFileToDefinition: (file, line) ->
    editorPane().showEditorForFile(file, line:line)
    @_resetSearch()

instance = -> new FindFunctionDefinition()

exports._class = FindFunctionDefinition
exports.register = ->
  $(document).bind('keydown', 'ctrl+/', -> instance().search())
