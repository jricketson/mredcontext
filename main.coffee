global.$ = $
global.console = console
global.document = document
global.CodeMirror = CodeMirror
global.Backbone = Backbone

require("coffee-script")
bootstrap = require("bootstrap")

$(document).ready ->
  bootstrap.bootstrap()