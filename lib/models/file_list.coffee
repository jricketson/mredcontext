folder_lib = require('./folder')
file_lib = require('./file')
configuration = require('../configuration').configuration
Backbone = require ('backbone')

class FileList extends Backbone.Collection
  initialize: (models) ->
    @_files = {}
    @root = new folder_lib.Folder(configuration.get('rootPath'))
    @foldersLeftToRead = [@root]
    @on('add', @_indexFile)

  _indexFile: (file) ->
    @_files[file.get('path')] = file

  getByPath: (path) ->
    @_files[path]

  startRead: ->
    @_startedReadingAt = new Date()
    @_deferRead()
    @_readDeferred = new $.Deferred()

  _deferRead: ->
    setTimeout(@_read, 1)

  _read: =>
    folder = @foldersLeftToRead.pop()
    unless folder?
      @_readDeferred.resolve(new Date() - @_startedReadingAt)
      return 
    folder.read().done =>
      for f in folder.files
        if f.constructor == file_lib.File
          #there might be an instance already here if it was loaded from the configuration
          #TODO: this leaves an incorrect reference within the Folder to the File that was constructed there.
          #This needs to be replaced with the one that was found in the collection.
          if (foundFile=@getByPath(f.get('path')))?
            foundFile.set(fileType: f.get('fileType'))
          else
            @add f
        else if f.constructor == folder_lib.Folder
          @foldersLeftToRead.push(f)
        else
          console.error("not an instance of anything #{f} #{f.constructor} #{folder.Folder}")

      @_deferRead()

exports.fileList = -> @_fileList ||= new FileList()

