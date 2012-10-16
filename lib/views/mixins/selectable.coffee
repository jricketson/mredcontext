#requires the following methods to be be implemented on the class
  #_resultSelected
#and these events to be registerd
#    "click .results .item": "_selectItem"
#    "keyup" : "_onkeypressed"

exports.selectableReset= ->
    @_selectedIndex = -1  
    @_removeResults()

exports._selectItem= (e) -> @_resultSelected($(e.currentTarget))

exports._onkeypressed= (e) -> 
    switch $.hotkeys.specialKeys[e.which]
      when "up" then @_goUp(e)
      when "down" then @_goDown(e)
      when "return" then @_chooseSelection()
      when "esc" then @hide()

exports._chooseSelection= (e) ->
    @_resultSelected(@$el.find('.results .item').eq(@_selectedIndex))

exports._goUp= (e) ->
    @_selectedIndex-=1
    @_highlightSelection()

exports._goDown= (e) ->
    @_selectedIndex+=1
    @_highlightSelection()

exports._highlightSelection= ->
    @$el.find('.results .item.highlighted').removeClass('highlighted')
    return if @_selectedIndex < 0
    @$el.find('.results .item').eq(@_selectedIndex).addClass('highlighted')

exports._removeResults= -> @$el.find(".results").empty()
