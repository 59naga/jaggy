{Frames, Frame, Color, Rect, Point}= require '../src/classes'

describe 'Classes',->
  it 'Convert to <g> by Frame',->
    frame= new Frame
    expect(frame.toG().outerHTML).toEqual('<g></g>')

  it 'Convert to <path> by Color',->
    color= new Color
    expect(color.toPath('').outerHTML).toEqual('<path></path>')

  it 'Color has points',->
    color= new Color
    expect(JSON.stringify color).toEqual('{"points":[]}')

  it 'Point is {x,y}',->
    point= new Point 0,0
    expect(JSON.stringify point).toEqual('{"x":0,"y":0}')

  it 'Rect like a Point ',->
    point= new Point 0,0
    rect= new Rect point
    expect(JSON.stringify rect).toMatch((JSON.stringify point).slice(-1))

  it 'Rect is M0,0h1v1h-1Z',->
    rect= new Rect x:0,y:0
    expect(rect.toD()).toEqual('M0,0h1v1h-1Z')
