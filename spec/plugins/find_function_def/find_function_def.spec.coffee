findFunctionDef = require("#{process.cwd()}/plugins/find_function_def")
fileList = require("#{process.cwd()}/lib/models/file_list").fileList
editorPane = require("#{process.cwd()}/lib/views/editor_pane_view").editorPane

describe 'FindFunctionDefinition', ->
  beforeEach ->
    @findFunctionDef = new findFunctionDef._class()

  describe '#cancel()', -> 
    beforeEach ->
      global.clearTimeout = jasmine.createSpy()
      @findFunctionDef._timer = 4
      @findFunctionDef._index = 5
      @findFunctionDef.cancel()

    it 'clears timeout', ->
      expect(@findFunctionDef._timer).toBeNull()
      expect(global.clearTimeout.callCount).toEqual(1)

    it 'resets the search index', ->
      expect(@findFunctionDef._index).toEqual(0)

  describe '#search()', ->
    beforeEach ->
      spyOn(@findFunctionDef, '_resetSearch')
      spyOn(editorPane(), 'getSelection')
      @findFunctionDef.search()

    it 'resets search to start with', ->
      expect(@findFunctionDef._resetSearch).toHaveBeenCalled()

    it 'searches each file in the fileList'

    it 'returns any matches'


  describe '.register()', ->
    beforeEach ->
      spyOn($.fn,'bind')
      findFunctionDef.register()

    it 'binds a key event for ctrl+/', ->
      expect($.fn.bind).toHaveBeenCalledWith('keydown', 'ctrl+/', jasmine.any(Function))
