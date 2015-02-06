gulp= require 'gulp'

files= '*.coffee'
specs= '*.spec.coffee'
gulp.task 'test',->
  gulp.src specs
    .pipe require('gulp-jasmine')
      timeout: 3000
      verbose: true
      # includeStackTrace: true

gulp.task 'default',->
  gulp.start 'test'
  watch= require 'gulp-watch'
  watch files,-> gulp.start 'test'

  livereload= require 'gulp-connect'
  livereload.server 
    livereload: true
    port: 59798
    root: 'public_html'
  
  gulp.src "public_html/**"
    .pipe watch "public_html/**"
    .pipe livereload.reload()

gulp.task 'browserify',(done)->
  source= require 'vinyl-source-stream'
  browserify= require 'browserify'
  browserify
      entries: "./jaggy.coffee"
      extensions: '.coffee'
    .require 'get-pixels'
    .require 'gify-parse'
    .exclude 'node_modules/**'
    .transform 'coffeeify'
    .bundle()
    .pipe source 'jaggy.browser.js'
    .pipe gulp.dest 'sources'
    .on 'end',->
      filename= 'sources/jaggy.browser.js'
      mainfile= 'sources/jaggy.browser.min.js'

      exec= require('child_process').exec
      exec "node_modules/.bin/uglifyjs #{filename} > #{mainfile}",()->
        fs= require 'fs'
        fs.unlinkSync filename
        done()
  return