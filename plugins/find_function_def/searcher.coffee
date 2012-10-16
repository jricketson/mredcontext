fileList = require("#{process.cwd()}/lib/models/file_list").fileList
editorPane = require("#{process.cwd()}/lib/views/editor_pane_view").editorPane

class Searcher
  DELAY:1

  constructor: ->
    @resetSearch()

  search: (searchString)->
    @resetSearch()
    @_regex = new RegExp(searchString + '\\s*[:=]\\s*\\(?.*\\)?[-=]>')
    @_search()
    @_promise

  resetSearch: ->
    global.clearTimeout(@_timer) if @_timer?
    @_index = 0
    @_timer = null
    @_promise = new $.Deferred()

  #This stops at the first match and opens it, maybe we want to show all matches incrementally?
  _search: =>
    if (f=fileList().at(@_index))?
      if f.get('fileType') == 'coffeescript'
        @_findLineMatching(f).
          done( (lineNumber, line) =>
            @_promise.notify(f, lineNumber, line)
            @_delaySearch()
          ).
          fail(@_delaySearch)
      else
        @_delaySearch()

  _delaySearch: =>
    @_index += 1
    @_timer = setTimeout(@_search, Searcher.DELAY)

  _findLineMatching: (file, functionName) ->
    promise = new $.Deferred()
    file.loadFromDiskIfNeeded().done(=>
      for line, index in file.get('content').split("\n")
        return promise.resolve(index, line) if @_regex.test(line)
      promise.reject()
    )
    promise

exports.Searcher = Searcher