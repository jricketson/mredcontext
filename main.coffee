global.$ = $
global.console = console
global.document = document
global.CodeMirror = CodeMirror
global.Backbone = Backbone
global.process = process

require("coffee-script")
bootstrap = require("bootstrap")

$(document).ready ->
  bootstrap.bootstrap()