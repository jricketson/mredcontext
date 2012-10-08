fs = require("fs")
path = require("path")

map =
  coffeescript: ["coffee"]
  ruby:         ["rb"]
  coffeescript: ["coffee"]
  css:          ["sass", "css"]
  html:         ["htmlembedded"]

cached = {}
exports.stat = (filepath) ->
  try
    stat = fs.statSync(filepath)
    if stat.isDirectory()
      return "folder"
    else
      ext = path.extname(filepath).substr(1)
      return cached[ext] if cached[ext]?
      for key of map
        if ext in map[key]
          cached[ext] = key
          return key
      return "blank"
  catch e
    console.error e
  return "error"