jaggy= require '../'

gulp= require 'gulp'
fs= require 'fs'

gutil= require 'gulp-util'
path= require 'path'
fs= require 'fs'

describe 'jaggy',->
  describe 'Usage for gulp',->
    it 'Convert to <svg> by .gif',(done)->
      gulp.src 'public/*.gif'
        .pipe jaggy()
        .pipe gulp.dest 'public'
        .on 'data',(file)->
          svg= fs.readFileSync(file.path).toString()
          expect(svg.indexOf("rgba(,,,NaN)")).toEqual -1
        .on 'end',->
          done()

    it 'Convert to <svg> by .png',(done)->
      gulp.src 'public/*.png'
        .pipe jaggy()
        .pipe gulp.dest 'public'
        .on 'data',(file)->
          svg= fs.readFileSync(file.path).toString()
          expect(svg.indexOf("rgba(,,,NaN)")).toEqual -1
        .on 'end',->
          done()

    it 'Convert to <svg> by .jpg',(done)->
      gulp.src 'public/*.jpg'
        .pipe jaggy()
        .pipe gulp.dest 'public'
        .on 'data',(file)->
          svg= fs.readFileSync(file.path).toString()
          expect(svg.indexOf("rgba(,,,NaN)")).toEqual -1
        .on 'end',->
          done()

    it 'Glitch to <svg> by .png',(done)->
      gulp.src 'public/yuno.png'
        .pipe jaggy glitch:3
        .pipe gulp.dest 'public'
        .on 'data',(file)->
          svg= fs.readFileSync(file.path).toString()
          expect(svg.indexOf("rgba(,,,NaN)")).toEqual -1
        .on 'end',->
          done()

    it 'Convert to pixels by gutil.File',(done)->
      file= new gutil.File
        cwd: process.cwd()
        base: "#{process.cwd()}/public/"
        path: "#{process.cwd()}/public/moon.png"
        contents: fs.readFileSync "#{process.cwd()}/public/moon.png"

      jaggy.readImageData file,(error,pixels)->
        expect(error).toEqual(null)
        expect(pixels.data.length).toEqual(96*192*4)
        expect(JSON.stringify pixels.shape).toEqual('[96,192,4]')

        done()