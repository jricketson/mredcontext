fileList = require('models/file_list').fileList
editorPane = require('views/editor_pane_view').editorPane

class FindFunctionDefinition
  DELAY:1
  constructor: ->
    @_index=0

  run: ->
    @selection = @_findSelection()
    #This stops at the first match and opens it, maybe we want to show all matches incrementally?
    @_regex = new RegExp(@selection + '\\s*[:=]\\s*\\(?.*\\)?[-=]>')
    console.log("searching for #{@_regex}")
    @_search()

  cancel: ->
    clearTimeout(@_timer) if @_timer?

  _findSelection: ->
    editorPane().activeEditor().getSelection()

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

instance = -> new FindFunctionDefinition()

exports.register = ->
  $(document).bind('keydown', 'ctrl+/', -> instance().run())
