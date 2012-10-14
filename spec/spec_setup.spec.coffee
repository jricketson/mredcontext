describe 'test setup', ->
  it 'stubs jquery properly', ->
    a = new $()
    expect(a instanceof $).toBeTruthy()

describe 'jasmine-node', ->

  it 'should pass', ->
    expect(1+2).toEqual(3)