file_list = require('file_list')

global.$ = $
global.console = console


$(document).ready ->
  for i in [1..4]
    myCodeMirror = CodeMirror($("#editor#{i}")[0], 
      value: "function myScript(){return 100;}\n"
      mode:  "javascript"
    )
  file_list = new file_list.FileList(process.cwd())
  file_list.startRead().always ->
    console.log(file_list)
  window.file_list = file_list