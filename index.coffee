Jaggy= (options,args...)->
  Jaggy.gulpPlugin options if args.length is 0

describe= (require 'debug')('jaggy')

Jaggy.gulpPlugin= (options={})->
  gutil= require 'gulp-util'
  through2= require 'through2'
  return through2.obj (file,encode,next)->
    return @emit 'error',new gutil.PluginError 'jaggy','Streaming not supported' if file.isStream()

    describe 'Convert to pixelArray by Image'
    Jaggy.readImageData file,(error,pixels)=>
      throw error if error?

      describe 'Convert to Palette by pixelArray'
      palette= Jaggy.convert pixels,options

      describe 'Create <svg> by Palette'
      svg= palette.toSVG options
      svg= options.afterConvert svg,palette,file if typeof options.afterConvert is 'function'

      file.path= gutil.replaceExtension file.path,'.svg'
      file.contents= new Buffer svg.outerHTML.replace ' viewbox=',' viewBox='# fix lowerCamel
      @push file

      next()

Jaggy.readImageData= (file,callback)->
  return callback 'file is not object' if typeof file isnt 'object'
  
  mime= require 'mime'
  mimeType= mime.lookup file.path
  getPixels= require 'get-pixels'
  getPixels (new Buffer file.contents),mimeType,callback

Jaggy.convert= (imagedata,options={})->
  throw new Error 'AnimationGif is not supported. Coming soon.' if imagedata.shape.length is 4

  if imagedata.width is undefined
    [width,height,channels]= imagedata.shape
    imagedata.width= width
    imagedata.height= height

  palette= new Jaggy.Palette imagedata.width,imagedata.height

  i= 0
  increment= if options.glitch then options.glitch else 4
  while imagedata.data[i] isnt undefined
    if imagedata.data[i+3] isnt 0
      values= []
      values.push imagedata.data[i+0]
      values.push imagedata.data[i+1]
      values.push imagedata.data[i+2]
      values.push (imagedata.data[i+3]/255).toFixed(2)
      
      rgba= 'rgba('+values.join(',')+')'
      if palette[rgba] is undefined
        palette[rgba]= new Jaggy.Color

      x= (i/4)% imagedata.width
      y= ~~((i/4)/imagedata.width)
      palette[rgba].put (new Jaggy.Point x,y)

    i= if typeof increment is 'function' then increment(i) else i+increment

  palette

class Jaggy.Palette# has many Color
  constructor: (@width,@height,@attrs={})->
    @attrs['shape-rendering']?= 'crispEdges'
    @attrs['version']?=         '1.1'
    @attrs['xmlns']?=           'http://www.w3.org/2000/svg'
    @attrs['xmlns:xlink']?=     'http://www.w3.org/1999/xlink'
    @attrs['viewBox']?=         "0 0 #{@width} #{@height}"
    @attrs['width']?=           @width
    @attrs['height']?=          @height

  toSVG:(options={})->
    dom= document ? require('dom-lite').document

    svg= dom.createElement 'svg'
    svg.setAttribute key,value for key,value of @attrs
    svg.appendChild this.toG options
    svg

  toG:(options={})->
    dom= document ? require('dom-lite').document

    g= dom.createElement 'g'
    for rgba,color of this
      g.appendChild color.toPath rgba,options if color instanceof Jaggy.Color
    g

class Jaggy.Color# has many Rect in @points
  constructor:(@points=[])->
  put:(point)-> @points.push point

  toPath:(fill='black',options={})->
    dom= document ? require('dom-lite').document

    path= dom.createElement 'path'
    path.setAttribute 'fill',fill if fill.length
    path.setAttribute 'd',@getRects(options).map((rect)->rect.toD()).join '' if @points.length
    path

  getRects:(options={})->
    rects= []

    # Merge @points for horizontal
    for point in @points
      left= rects[rects.length-1]|| {}
      is_left= left.y is point.y and (left.x+left.width) is point.x
      if is_left and options.fullPixel isnt true
        left.width++
        continue
      # top= 

      rects.push point.toRect options

    rects

class Jaggy.Rect
  constructor: (point)->
    @x= point.x
    @y= point.y
    @width= 1
    @height= 1

  toD: ->
    # 1pixel = <path d='M0,0 h1 v1 h-1 z'>
    'M'+@x+','+@y+'h'+@width+'v'+@height+'h-'+@width+'Z';

class Jaggy.Point
  constructor: (@x,@y)->
  toRect:(options={})->
    new Jaggy.Rect this

module.exports= Jaggy