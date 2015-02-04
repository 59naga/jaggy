Jaggy= (options,args...)->
  Jaggy.gulpPlugin options if args.length is 0

debug= (require 'debug')('vectorizer')

Jaggy.gulpPlugin= (options={})->
  gutil= require 'gulp-util'
  through2= require 'through2'
  return through2.obj (file,encode,next)->
    return @emit 'error',new gutil.PluginError 'gulp-vectorizer','Streaming not supported' if file.isStream()

    self= this
    isGulpBuffer= typeof file is 'object'
    if isGulpBuffer
      mime= require 'mime'
      mimeType= mime.lookup file.path

      debug 'convet to pixelArray by Image'

      getPixels= require 'get-pixels'
      getPixels (new Buffer file.contents),mimeType,(error,pixels)->
        throw error if error?

        debug 'convert to colors by pixelArray'
        colors= Jaggy.convert pixels,options

        debug 'create svg by colors'
        dom= document ? require('dom-lite').document

        svg= dom.createElement 'svg'
        svgAttrs=
          "shape-rendering": "crispEdges"
          "version": "1.1"
          "xmlns": "http://www.w3.org/2000/svg"
          "xmlns:xlink": "http://www.w3.org/1999/xlink"
          "viewBox": "0 0 #{colors.width} #{colors.height}"
          "width": colors.width
          "height": colors.height
        svg.setAttribute key,value for key,value of svgAttrs

        g= dom.createElement 'g'
        paths= colors.toPaths options
        paths.forEach (pathAttrs)->
          path= dom.createElement 'path'
          path.setAttribute key,value for key,value of pathAttrs
          g.appendChild path

        svg.appendChild g

        svg= options.afterConvert svg,colors,file if typeof options.afterConvert is 'function'

        debug 'emit Buffer'

        svgHTML= svg.outerHTML.replace ' viewbox=',' viewBox='# fix lowerCamel
        file.path= gutil.replaceExtension file.path,'.svg'
        file.contents= new Buffer svgHTML
        self.push file

        next()

Jaggy.convert= (imagedata,options={})->
  throw new Error 'AnimationGif is not supported. Coming soon.' if imagedata.shape.length is 4

  if imagedata.width is undefined
    [width,height,channels]= imagedata.shape
    imagedata.width= width
    imagedata.height= height

  colors= new Jaggy.Colors imagedata.width,imagedata.height

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
      if colors[rgba] is undefined
        colors[rgba]= new Jaggy.Color

      x= (i/4)% imagedata.width
      y= ~~((i/4)/imagedata.width)
      colors[rgba].put (new Jaggy.Point x,y)

    i= if typeof increment is 'function' then increment(i) else i+increment

  colors

class Jaggy.Colors# has many Color
  constructor: (@width,@height)->
  toPaths:(options={})->
    paths= []
    for rgba,color of this
      paths.push color.toPath rgba,options if typeof color is 'object'
    paths

class Jaggy.Color# has many Rect in @points
  constructor:(@points=[])->
  put:(color)-> @points.push color

  toPath:(fill='black',options={})->
    path= {}
    path.fill= fill
    path.d= @toRects(options).map((rect)->rect.toD()).join ''
    path

  toRects:(options={})->
    rects= []

    # Merge @points for horizontal
    for point in @points
      left= rects[rects.length-1]|| {}
      is_left= left.y is point.y and (left.x+left.width) is point.x
      if is_left and options.fullPixel isnt true
        left.width++
        continue

      rects.push (new Jaggy.Rect point)

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

module.exports= Jaggy