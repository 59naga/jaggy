gulp= require 'gulp'

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
      script= "cp #{filename} #{mainfile}"
      script= "node_modules/.bin/uglifyjs #{filename} > #{mainfile}" if '-min' in process.argv

      exec= require('child_process').exec
      exec script,()->
        fs= require 'fs'
        fs.unlinkSync filename
        done()
  return