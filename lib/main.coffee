global.$ = $
global.console = console

$(document).ready ->
  for i in [1..4]
    myCodeMirror = CodeMirror($("#editor#{i}")[0], 
      value: "function myScript(){return 100;}\n"
      mode:  "javascript"
    )
