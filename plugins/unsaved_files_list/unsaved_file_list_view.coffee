Haml = require('haml')
mixin = require("#{process.cwd()}/lib/mixin")
movable = require("#{process.cwd()}/lib/views/mixins/movable")

class UnsavedFileListView extends Backbone.View

  id: 'unsavedFileList'
  events:
    'mousedown': '_startMoving'
    'click .unsavedFiles .item': '_saveFile'

  template: Haml """
    .titleBar.moveHandle
      save these
    .unsavedFiles
  """
  fileTemplate: Haml """
    .item(data-path=file.get('path'))
      .name= file.projectPath()
  """

  initialize: ->
    #TODO: this might be a performance problem later, but probably not. Should only render once.
    @model.on('add', => @_renderFiles())
    @model.on('remove', => @_renderFiles())

  render: ->
    @$el.html(@template())
    @_renderFiles()
    @

  _renderFiles: ->
    @$el.find('.unsavedFiles').empty()
    if @model.length > 0
      @show()
      for m in @model.models
        @_appendFile(m)
    else
      @hide()

  show: ->
    @$el.slideDown()
  hide: ->
    @$el.slideUp()

  _saveFile: (e) ->
    @model.getByPath($(e.currentTarget).data('path')).writeContentsToDisk()

  _appendFile: (file) ->
    @$el.find('.unsavedFiles').append(@fileTemplate(file:file))

mixin.include(UnsavedFileListView, movable)
exports.UnsavedFileListView = UnsavedFileListView