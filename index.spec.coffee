Jaggy= require './index.coffee'
gulp= require 'gulp'

describe 'Jaggy behavior',->
  it 'Convert png to svg',(done)->
    gulp.src 'fixtures/*.png'
      .pipe Jaggy()
      .pipe gulp.dest 'public_html'
      .on 'end',done