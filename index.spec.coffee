Jaggy= require './index.coffee'
gulp= require 'gulp'

describe 'Jaggy',->
  it 'Convert to <svg> by .png',(done)->
    gulp.src 'fixtures/*.png'
      .pipe Jaggy()
      .pipe gulp.dest 'public_html'
      .on 'end',done

  it 'Convert to <svg> by Palette',->
    palette= new Jaggy.Palette 1,1
    palette.attrs= {}
    expect(palette.toSVG().outerHTML).toEqual('<svg><g></g></svg>')

  it 'Convert to pixels by gutil.File',(done)->
    gutil= require 'gulp-util'
    path= require 'path'
    fs= require 'fs'

    file= new gutil.File
      cwd: __dirname
      base: "#{__dirname}/fixtures/"
      path: "#{__dirname}/fixtures/moon.png"
      contents: fs.readFileSync "#{__dirname}/fixtures/moon.png"

    Jaggy.readImageData file,(error,pixels)->
      expect(error).toEqual(null)
      expect(pixels.data.length).toEqual(96*192*4)
      expect(JSON.stringify pixels.shape).toEqual('[96,192,4]')
      done()

  it 'Convert to <g> by Palette',->
    palette= new Jaggy.Palette
    expect(palette.toG().outerHTML).toEqual('<g></g>')

  it 'Convert to <path> by Color',->
    color= new Jaggy.Color
    expect(color.toPath('').outerHTML).toEqual('<path></path>')

  it 'Color has points',->
    color= new Jaggy.Color
    expect(JSON.stringify color).toEqual('{"points":[]}')

  it 'Point is {x,y}',->
    point= new Jaggy.Point 0,0
    expect(JSON.stringify point).toEqual('{"x":0,"y":0}')

  it 'Rect like a Point ',->
    point= new Jaggy.Point 0,0
    rect= new Jaggy.Rect point
    expect(JSON.stringify rect).toMatch((JSON.stringify point).slice(-1))

  it 'Rect is M0,0h1v1h-1Z',->
    rect= new Jaggy.Rect x:0,y:0
    expect(rect.toD()).toEqual('M0,0h1v1h-1Z')
