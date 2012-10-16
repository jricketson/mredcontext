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
    @_deferRun()
    @_promise

  currentSearch: -> @_searchString

  _deferRun: ->
    setTimeout(@_deferredRun, 10)

  _deferredRun: =>
    matchBit = @_searchString.replace(new RegExp(' ','g'),'').split('').join(Searcher.ANY)
    findAllPattern = new RegExp(";#{Searcher.ANY}#{matchBit}#{Searcher.ANY};",'gi')
    initialMatches = @_state.searchIndex.match(findAllPattern)
    findPartsPattern = new RegExp(";(#{Searcher.ANY}(#{matchBit})#{Searcher.ANY});",'i')
    matches = for match in initialMatches
      parts = match.match(findPartsPattern)
      {
        filename: parts[1]
        length: parts[2].length
      }
    matches.sort((a,b) -> a.length - b.length)
    for m in matches[0..Searcher.SEARCH_LIMIT]
      @_promise.notify(m.filename)
    @_promise.resolve()
    @resetSearch()

exports.Searcher = Searcher