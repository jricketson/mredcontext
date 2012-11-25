(function() {
  var bootstrap;
  global.$ = $;
  global.jQuery = jQuery;
  global.console = console;
  global.document = document;
  global.CodeMirror = CodeMirror;
  global.process = process;
  global._instances={}
  global.GUI = require('nw.gui');

  require("coffee-script");
  global.Backbone = require('backbone'); //# TODO: make this not required for running tests
  global._ = require('underscore'); //# TODO: make this not required for running tests
  require('backbone-filtered-collection');
  application = require("./lib/application").application();
  
  $(document).ready(function() {
    application.bootstrap();
  });

}).call(this);
