gulp= require 'gulp'

files= '*.coffee'
specs= '*.spec.coffee'
gulp.task 'test',->
  gulp.src specs
    .pipe require('gulp-jasmine')
      timeout: 3000
      verbose: true
      includeStackTrace: true

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