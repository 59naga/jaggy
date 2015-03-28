Jaggy= ->
  Jaggy.createSVG.apply null,arguments if typeof window isnt 'undefined'
  Jaggy.gulpPlugin.apply null,arguments if typeof window is 'undefined'

Jaggy.cli= ->
  cli= new (require 'commander').Command
  cli
    .version require('../package.json').version
    .usage 'file/directory [options...]'
    .option '-r recursive','Convert pixelarts in recursive directory'
    .option '-o output <directory>','Output directory <./>','.'
    .option '-g --glitch <increment>','Glitch color palettes <4>',4
    .parse process.argv
  cli.help() if cli.args.length is 0

  path= require 'path'
  globs= []
  for arg in cli.args
    if arg.match(/(\.gif|\.jpg|\.png)$/)
       glob= path.resolve arg
    else
      glob= path.resolve "#{arg}/*.+(gif|png|jpg)"
      glob= path.resolve "#{arg}/**/*.+(gif|png|jpg)" if cli.recursive
    globs.push glob
  globs.push '!**/*.!(*gif|*png|*jpg)' # Ignore unsupport extension

  gulp= require 'gulp'
  gulp.src globs,base:process.cwd()
    .pipe Jaggy.gulpPlugin glitch:cli.glitch
    .pipe gulp.dest path.resolve cli.output
    .on 'data',(file)-> console.log 'Convert',path.relative process.cwd(),file.path.replace(/(\.gif|\.jpg|\.png)$/,'.svg')
    .on 'end',->
      process.exit()

Jaggy.gulpPlugin= (options={})->
  gutil= require 'gulp-util'
  through2= require 'through2'
  return through2.obj (file,encode,next)->
    return @emit 'error',new gutil.PluginError 'jaggy','Streaming not supported' if file.isStream()

    Jaggy.readImageData file,(error,pixels)=>
      throw error if error?

      Jaggy.convertToSVG pixels,options,(error,svg)=>
        throw error if error?

        file.path= gutil.replaceExtension file.path,'.svg'
        file.contents= new Buffer svg
        @push file

        next()

# Use url for browser
Jaggy.createSVG= (url,args...)->
  throw new Error 'url is not string' if typeof url isnt 'string'
  callback= null
  options= {}
  args.forEach (arg)-> switch typeof arg
    when 'function' then callback= arg
    when 'object' then options= arg
  options.outerHTML?= false
  
  getPixels= require 'get-pixels'
  getPixels url,(error,pixels)->
    return callback error if error?

    if pixels.shape.length is 3
      Jaggy.convertToSVG pixels,options,callback

    if pixels.shape.length is 4
      xhr= new XMLHttpRequest
      xhr.open 'GET',url,true
      xhr.responseType= 'arraybuffer'
      xhr.send()
      xhr.onerror= -> callback xhr.statusText
      xhr.onload= ->
        gifyParse= require 'gify-parse'
        anime= gifyParse.getInfo xhr.response
        anime.delays= anime.images.map (image)-> image.delay
        anime.disposals= anime.images.map (image)-> image.disposal
        pixels.anime= anime

        Jaggy.convertToSVG pixels,options,callback

# Use for angular.js
Jaggy.angularModule= (window)->
  angularModule= window.angular.module 'jaggy',[]
  angularModule.directive 'jaggy',->
    (scope,element,attrs)->
      element.css 'display','none'

      options= {}
      if attrs.jaggy
        for param in attrs.jaggy.split ';'
          [key,value]= param.split ':'
          options[key]= value

      #fix <img ng-src="" jaggy>
      url= attrs.src
      url?= attrs.ngSrc

      Jaggy.createSVG url,options,(error,svg)->
        throw error if error?
        element.replaceWith svg

Jaggy.convertToSVG= (pixels,args...)->
  callback= null
  options= {}
  args.forEach (arg)-> switch typeof arg
    when 'function' then callback= arg
    when 'object' then options= arg
  options.glitch= +options.glitch if typeof options.glitch is 'string'
  return callback new Error('glitch is 0') if options.glitch is 0

  jaggy= Jaggy.convert pixels,options

  svg= jaggy.toSVG options
  svg= options.afterConvert svg,jaggy,file if typeof options.afterConvert is 'function'

  if options.outerHTML isnt false
    svg= svg.outerHTML.replace ' viewbox=',' viewBox='# fix to lowerCamel
    svg= svg.replace(/&gt;/g,'>')# enable querySelector

  callback null,svg

Jaggy.enableAnimation= (svg)->
  throw new Error('Can enable appended element only') if svg.parentNode is null

  # fix disabled script
  script= svg.querySelector 'script'
  script.parentNode.replaceChild script.cloneNode(),script
  svg

# Use Buffer for node.js
Jaggy.readImageData= (file,callback)->
  return callback 'file is not object' if typeof file isnt 'object'
  
  buffer= new Buffer file.contents

  mime= require 'mime'
  mimeType= mime.lookup file.path

  getPixels= require 'get-pixels'
  getPixels buffer,mimeType,(error,pixels)->
    return callback error if error?

    if pixels.shape.length is 4
      gifyParse= require 'gify-parse'
      anime= gifyParse.getInfo buffer
      anime.delays= anime.images.map (image)-> image.delay
      anime.disposals= anime.images.map (image)-> image.disposal
      pixels.anime= anime

    callback null,pixels

Jaggy.convert= (pixels,options={})->
  throw new Error 'Not supported File' if pixels?.shape?.length is undefined

  [width,height,channel]= pixels.shape if pixels.shape.length is 3
  [frame,width,height,channel]= pixels.shape if pixels.shape.length is 4
  pixels.frame= frame ? 1
  pixels.width= width
  pixels.height= height
  pixels.channel= channel

  Frames= (require './classes.coffee').Frames
  new Frames pixels,options

if typeof window isnt 'undefined'
  window.jaggy= Jaggy
  Jaggy.angularModule window if typeof window.angular is 'object'
else
  module.exports= Jaggy if typeof window is 'undefined'