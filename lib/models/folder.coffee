fs = require('fs')
path = require('path')
mime = require('../mime')
file = require('./file')

class Folder
  constructor: (@path) ->
    @files = []

  read: ->
    fs.readdir(@path, (error, files) =>
      if (error)
        console.error("This path had an error '#{@path}'")
        console.error(error)
        @_readDeferred.reject(error)
        return

      for f in files
        if f[0] != '.' #if it is hidden
          fullPath = path.join(@path, f)
          fileType = mime.stat(fullPath)
          if fileType == 'folder'
            @files.push new Folder(fullPath)
          else
            @files.push new file.File(path:fullPath, fileType:fileType)
      @_readDeferred.resolve()
    )
    @_readDeferred = new $.Deferred()

module.exports.Folder = Folder
