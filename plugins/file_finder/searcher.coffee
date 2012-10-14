class Searcher
  @ANY: '[^;]*'
  @SEARCH_LIMIT=100

  constructor: (@_state) ->

  resetSearch: ->
    clearTimeout(@_timeout) if @_timeout?
    @_count = 0

  filesMatching: (@_searchString) ->
    @resetSearch()
    @_promise = new $.Deferred()
    components = [
      Searcher.ANY, 
      @_searchString.replace(new RegExp(' ','g'),'').split('').join(Searcher.ANY),
      Searcher.ANY
    ]
    @_pattern = new RegExp(";(#{components.join('')});",'gi')
    @_deferRun()
    @_promise

  _deferRun: ->
    @_count+=1
    @_timeout = setTimeout(@_filesMatching, 10) if @_count < Searcher.SEARCH_LIMIT

  _filesMatching: =>
    if (match=@_pattern.exec(@_state.searchIndex))?
      @_promise.notify(match[1])
      @_deferRun()
    else
      @_promise.resolve()
      @resetSearch()

exports.Searcher = Searcher