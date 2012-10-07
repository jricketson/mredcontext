class UnsavedFileCollection extends Backbone.FilteredCollection
  collectionFilter: (item) ->
    item.isDirty()

  getByPath: (path) ->
    #this is always going to be a small collection
    for m in @models
      return m if m.get('path') == path

exports.UnsavedFileCollection = UnsavedFileCollection