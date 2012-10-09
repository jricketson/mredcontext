(function() {
  var bootstrap;
  global.$ = $;
  global.console = console;
  global.document = document;
  global.CodeMirror = CodeMirror;
  global.Backbone = Backbone;
  global.process = process;
  global._ = _;

  require("coffee-script");
  bootstrap = require("bootstrap");

  $(document).ready(function() {
    return bootstrap.bootstrap();
  });

}).call(this);
