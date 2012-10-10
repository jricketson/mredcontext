UnsavedFileList = require('./unsaved_file_list_view')
UnsavedFileCollection = require('./unsaved_file_collection')
fileList = require('../../lib/models/file_list').fileList

exports.register = ->
  unsavedFileCollection = new UnsavedFileCollection.UnsavedFileCollection(null, collection:fileList())
  unsavedFileList = new UnsavedFileList.UnsavedFileListView(model:unsavedFileCollection)
  $("body").append unsavedFileList.render().el
