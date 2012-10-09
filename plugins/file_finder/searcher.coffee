class Searcher
  @ANY: '[^;]*'
  @SEARCH_LIMIT=100

  constructor: (@state) ->

  resetSearch: ->
    clearTimeout(@timeout) if @timeout?
    @count= 0

  filesMatching: (@searchString) ->
    @resetSearch()
    @promise = new $.Deferred()
    components = [
      Searcher.ANY, 
      searchString.replace(new RegExp(' ','g'),'').split('').join(Searcher.ANY),
      Searcher.ANY
    ]
    @pattern = new RegExp(";(#{components.join('')});",'gi')
    @timeout = setTimeout(@_filesMatching, 10)
    @promise

  _filesMatching: =>
    if (match=@pattern.exec(@state.searchIndex))?
      @promise.notify(match[1])
      @count+=1
      @timeout = setTimeout(@_filesMatching, 10) if @count < Searcher.SEARCH_LIMIT
    else
      @promise.resolve()
      @resetSearch

exports.Searcher = Searcher