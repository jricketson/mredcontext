fs = require ('fs')
FileModel = require('./models/file')
fileList = require('./models/file_list').fileList
editorPane = require('./views/editor_pane_view').editorPane
configuration = require('./configuration').configuration

setupShortcuts= ->
  $(document).bind('keydown', 'ctrl+s', -> editorPane().saveActive())

reloadLayout= ->
  #To reload the layout before the filelist has finished loading, 
  #the filelist needs some smarts about finding files on disk vs ones that have already been found from reloading the layout
  console.log('reloading layout')
  layout = configuration.get('layout')
  for conf in layout || []
    file = fileList().getByPath(conf.path)
    unless file?
      file = new FileModel.File(path:conf.path)
      fileList().add(file)
    editorPane().showEditorForFile(file, position:conf.position)

loadPlugins= ->
  promise = new $.Deferred()
  fs.readdir("#{process.cwd()}/plugins", (error, files) =>
    for f in files
      if f[0] != '.'
        console.log("loading plugin #{f}")
        module = require("#{process.cwd()}/plugins/#{f}")
        module.register()
    promise.resolve()
  )
  promise

exports.bootstrap= ->
#  root_path = process.cwd() + "/"
  root_path="/home/jon/data/Projects/atlas/"
  console.log("Starting in '#{root_path}'")
  configuration.loadConfigFor(root_path).done -> 
    console.log('config loaded')
    loadPlugins().done ->
      console.log('plugins loaded')
      fileList().startRead().done (elapsedMilliSeconds) ->
        console.log("finished reading #{fileList().length} files in #{elapsedMilliSeconds}ms")
      reloadLayout()
      editorPane().on('layoutUpdated', (layout) -> configuration.set(layout:layout))  

      setupShortcuts()