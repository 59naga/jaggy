jaggy= require '../src'

gulp= require 'gulp'
fs= require 'fs'

gutil= require 'gulp-util'
path= require 'path'
fs= require 'fs'

describe 'jaggy',->
  describe 'Usage for gulp',->
    it 'Convert to <svg> by .gif',(done)->
      glob= 'public/*.gif'

      files= []
      gulp.src glob,{nocase:yes}
        .pipe jaggy()
        .on 'data',(file)-> files.push file
        .on 'end',->
          file= files[0]
          filePath= file?.path ? ''
          try
            svg= fs.readFileSync(filePath).toString()

          svg?= ''

          expect(files.length).toBe 2
          expect(svg.indexOf("rgba(,,,NaN)")).toEqual -1
          done()

    it 'Convert to <svg> by .png',(done)->
      glob= 'public/*.png'

      files= []
      gulp.src glob,{nocase:yes}
        .pipe jaggy()
        .on 'data',(file)-> files.push file
        .on 'end',->
          file= files[0]
          filePath= file?.path ? ''
          try
            svg= fs.readFileSync(filePath).toString()

          svg?= ''

          expect(files.length).toBe 2
          expect(svg.indexOf("rgba(,,,NaN)")).toEqual -1
          done()

    it 'Convert to <svg> by .jpg',(done)->
      glob= 'public/*.jpg'

      files= []
      gulp.src glob,{nocase:yes}
        .pipe jaggy()
        .on 'data',(file)-> files.push file
        .on 'end',->
          file= files[0]
          filePath= file?.path ? ''
          try
            svg= fs.readFileSync(filePath).toString()

          svg?= ''

          expect(files.length).toBe 1
          expect(svg.indexOf("rgba(,,,NaN)")).toEqual -1
          done()

    it 'Glitch to <svg> by .png',(done)->
      glob= 'public/yuno.PNG'

      files= []
      gulp.src glob,{nocase:yes}
        .pipe jaggy {glitch:3}
        .on 'data',(file)-> files.push file
        .on 'end',->
          file= files[0]
          filePath= file?.path ? ''
          try
            svg= fs.readFileSync(filePath).toString()

          svg?= ''

          expect(files.length).toBe 1
          expect(svg.indexOf("rgba(,,,NaN)")).toEqual -1
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
