Jaggy= require '../'
{Frames, Frame, Color, Rect, Point}= require '../lib/classes'

gulp= require 'gulp'
fs= require 'fs'

jasmine.DEFAULT_TIMEOUT_INTERVAL= 10000

describe 'Jaggy',->
  describe 'Usage for gulp',->
    it 'Convert to <svg> by .gif',(done)->
      gulp.src 'public/*.gif'
        .pipe Jaggy()
        .pipe gulp.dest 'public'
        .on 'data',(file)->
          svg= fs.readFileSync(file.path).toString()
          expect(svg.indexOf("rgba(,,,NaN)")).toEqual -1
        .on 'end',->
          done()

    it 'Convert to <svg> by .png',(done)->
      gulp.src 'public/*.png'
        .pipe Jaggy()
        .pipe gulp.dest 'public'
        .on 'data',(file)->
          svg= fs.readFileSync(file.path).toString()
          expect(svg.indexOf("rgba(,,,NaN)")).toEqual -1
        .on 'end',->
          done()

    it 'Convert to <svg> by .jpg',(done)->
      gulp.src 'public/*.jpg'
        .pipe Jaggy()
        .pipe gulp.dest 'public'
        .on 'data',(file)->
          svg= fs.readFileSync(file.path).toString()
          expect(svg.indexOf("rgba(,,,NaN)")).toEqual -1
        .on 'end',->
          done()

    it 'Glitch to <svg> by .png',(done)->
      gulp.src 'public/yuno.png'
        .pipe Jaggy glitch:3
        .pipe gulp.dest 'public'
        .on 'data',(file)->
          svg= fs.readFileSync(file.path).toString()
          expect(svg.indexOf("rgba(,,,NaN)")).toEqual -1
        .on 'end',->
          done()

    it 'Convert to pixels by gutil.File',(done)->
      gutil= require 'gulp-util'
      path= require 'path'
      fs= require 'fs'

      file= new gutil.File
        cwd: process.cwd()
        base: "#{process.cwd()}/public/"
        path: "#{process.cwd()}/public/moon.png"
        contents: fs.readFileSync "#{process.cwd()}/public/moon.png"

      Jaggy.readImageData file,(error,pixels)->
        expect(error).toEqual(null)
        expect(pixels.data.length).toEqual(96*192*4)
        expect(JSON.stringify pixels.shape).toEqual('[96,192,4]')

        done()

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