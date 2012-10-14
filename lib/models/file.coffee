fs = require('fs')
configuration = require('../configuration').configuration
Backbone = require ('backbone')

class File extends Backbone.Model

  rootPath: ''

  initialize: ->
    @set(content: '', dirty: false)
    @_alreadyLoaded = false
    @on('change:content', (o, update, options) => 
      if options.changes.content
        @set(dirty: true)
    )
    @_rootPath=configuration.get('rootPath')

  projectPath: -> @get('path').substr(@_rootPath.length)
  name: -> @get('path').split('/').pop()
  loaded: -> @_alreadyLoaded

  loadFromDiskIfNeeded: ->
    readPromise = new $.Deferred()
    if @_alreadyLoaded
      readPromise.resolve()
      return readPromise
    fs.readFile(@get('path'), 'utf8', (err, data) => 
      if err
        readPromise.reject(err)
        throw err
      @set({content: data, dirty: false}, {silent: true})
      @_alreadyLoaded = true
      @trigger('loaded:content')
      readPromise.resolve()
    )
    readPromise

  writeContentsToDisk: ->
    writePromise = new $.Deferred()
    fs.writeFile(@get('path'), @get('content'), 'utf8', (err) =>
      if err
        writePromise.reject(err)
        throw err
      @set(dirty: false)
      writePromise.resolve()
    )
    writePromise

  isDirty: ->
    @get('dirty')

  toString: ->
    "<File>:#{@projectPath()}"

module.exports.File = File