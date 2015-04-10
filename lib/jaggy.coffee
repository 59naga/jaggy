version= (require '../package.json').version
Frames= (require './classes').Frames

if not window?
  gutil= require 'gulp-util'
  through2= require 'through2'
  Command= (require 'commander').Command

  path= require 'path'
  gulp= require 'gulp'

  mime= require 'mime'

getPixels= require 'get-pixels'
gifyParse= require 'gify-parse'

jaggy= (options={})->
  through2.obj (file,encode,next)->
    return @emit 'error',new gutil.PluginError 'jaggy','Streaming not supported' if file.isStream()

    jaggy.readImageData file,(error,pixels)=>
      return @emit 'error',new gutil.PluginError 'jaggy',error if error?

      jaggy.convertToSVG pixels,options,(error,svg)=>
        return @emit 'error',new gutil.PluginError 'jaggy',error if error?

        file.path= gutil.replaceExtension file.path,'.svg'
        file.contents= new Buffer svg
        @push file

        next()

jaggy.convertToSVG= (pixels,args...)->
  callback= null
  options= {}
  args.forEach (arg)-> switch typeof arg
    when 'function' then callback= arg
    when 'object' then options= arg
  options.glitch= +options.glitch if typeof options.glitch is 'string'
  return callback new Error('glitch is 0') if options.glitch is 0

  frames= jaggy.convert pixels,options
  svg= frames.toSVG options

  # fix to domlite
  if not window?
    svg= svg.outerHTML.replace ' viewbox=',' viewBox='
    svg= svg.replace(/&gt;/g,'>')

  jaggy.setCache options.cacheUrl,svg,options if options.cacheUrl?

  callback null,svg

# Use Buffer for node.js
jaggy.readImageData= (file,callback)->
  return callback 'file is not object' if typeof file isnt 'object'
  
  buffer= new Buffer file.contents
  mimeType= mime.lookup file.path
  
  getPixels buffer,mimeType,(error,pixels)->
    return callback error if error?

    if pixels.shape.length is 4
      anime= gifyParse.getInfo buffer
      anime.delays= anime.images.map (image)-> image.delay
      anime.disposals= anime.images.map (image)-> image.disposal
      pixels.anime= anime

    callback null,pixels

jaggy.convert= (pixels,options={})->
  throw new Error 'Not supported File' if pixels?.shape?.length is undefined

  [width,height,channel]= pixels.shape if pixels.shape.length is 3
  [frame,width,height,channel]= pixels.shape if pixels.shape.length is 4
  pixels.frame= frame ? 1
  pixels.width= width
  pixels.height= height
  pixels.channel= channel

  new Frames pixels,options

jaggy.cli= ->
  cli= new Command
  cli
    .version version
    .usage 'file/directory [options...]'
    .option '-r recursive','Convert pixelarts in recursive directory'
    .option '-o output <directory>','Output directory <./>','.'
    .option '-g --glitch <increment>','Glitch color palettes <4>',4
    .parse process.argv
  cli.help() if cli.args.length is 0

  globs= []
  for arg in cli.args
    if arg.match(/(\.gif|\.jpg|\.png)$/)
       glob= path.resolve arg
    else
      glob= path.resolve "#{arg}/*.+(gif|png|jpg)"
      glob= path.resolve "#{arg}/**/*.+(gif|png|jpg)" if cli.recursive
    globs.push glob

  # Ignore unsupport extension
  globs.push '!**/*.!(*gif|*png|*jpg)'

  gulp.src globs,base:process.cwd()
    .pipe jaggy glitch:cli.glitch
    .pipe gulp.dest path.resolve cli.output
    .on 'data',(file)->
      from= path.relative process.cwd(),file.path
      to= gutil.replaceExtension from,'.svg'

      console.log 'Convert',to
    .on 'end',->
      process.exit 0

module.exports= jaggy