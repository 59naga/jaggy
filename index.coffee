Jaggy= (options,args...)->
  Jaggy.gulpPlugin options if args.length is 0

describe= (require 'debug')('jaggy')

Jaggy.createElement= document?.createElement ? require('dom-lite').document.createElement.bind require('dom-lite').document
Jaggy.createTextNode= document?.createTextNode ? require('dom-lite').document.createTextNode.bind require('dom-lite').document

Jaggy.gulpPlugin= (options={})->
  gutil= require 'gulp-util'
  through2= require 'through2'
  return through2.obj (file,encode,next)->
    return @emit 'error',new gutil.PluginError 'jaggy','Streaming not supported' if file.isStream()

    describe 'Convert to pixelArray by Image'
    Jaggy.readImageData file,(error,pixels)=>
      throw error if error?

      describe 'Convert to Frame by pixelArray'
      jaggy= Jaggy.convert pixels,options

      describe 'Create <svg> by Frame'
      svg= jaggy.toSVG options
      svg= options.afterConvert svg,jaggy,file if typeof options.afterConvert is 'function'

      html= svg.outerHTML.replace ' viewbox=',' viewBox='# fix lowerCamel
      html= html.replace(/&gt;/g,'>')# enable querySelector

      file.path= gutil.replaceExtension file.path,'.svg'
      file.contents= new Buffer html
      @push file

      next()

# Use node.js Buffer
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

  new Jaggy.Frames pixels,options

class Jaggy.Frames
  constructor:(image,options={})->
    @attrs= 
      'version': '1.1'
      'xmlns': 'http://www.w3.org/2000/svg'
      'xmlns:xlink': 'http://www.w3.org/1999/xlink'

      'shape-rendering': 'crispEdges'
      'width': image.width
      'height': image.height
      'viewBox': "0 0 #{image.width} #{image.height}"

    @frame_size= image.width*image.height*image.channel
    @frames= []
    @delays= image.anime || []

    i= 0
    while image.data[i*@frame_size] isnt undefined
      frame= new Jaggy.Frame
      frame.delay= image.anime.delays[i] if image.anime?
      frame.disposal= image.anime.disposals[i] if image.anime?
      frame.putImageData i*@frame_size,i*@frame_size+@frame_size,image,options
      @frames.push frame

      i++

  toSVG:->
    svg= Jaggy.createElement 'svg'
    svg.setAttribute key,value for key,value of @attrs
    if @frames.length is 1
      svg.appendChild @frames[0].toG()
    else
      svg.setAttribute 'id','A'+uuid()
      svg.appendChild @createAnime()
      svg.appendChild @createScript(svg.id)
    svg

  createAnime:->
    g= Jaggy.createElement 'g'
    g.setAttribute 'style','display:none'
    g.appendChild frame.toG() for frame in @frames
    g

  createScript:(id)->
    script= Jaggy.createElement 'script'
    script.appendChild Jaggy.createTextNode "(#{animation.toString()})('#{id}');"
    script

  # private

  animation= (id)->
    i= 0
    frames= [].slice.call document.querySelectorAll '#'+id+'>g>g'
    display= null

    setTimeout -> nextFrame()
    nextFrame=->
      frame= frames[i++]
      frame= frames[i= 0] if frame is undefined
      frame_id= frame.getAttribute 'id'
      if frame_id is null
        frame_id= id+'_'+('0000'+i).slice(-5) 
        frame.setAttribute 'id',frame_id

      if i is 0
        uses= document.querySelectorAll '#'+id+'>use'
        use.parentNode.removeChild use for use in uses

      createDisplay frame_id
      setTimeout nextFrame,frame.getAttribute 'delay'

    createDisplay=(frame_id)->
      display= document.createElementNS 'http://www.w3.org/2000/svg','use'
      display.setAttribute 'xmlns:xlink','http://www.w3.org/1999/xlink'
      display.setAttributeNS 'http://www.w3.org/1999/xlink','href','#'+frame_id if frame_id
      document.querySelector('#'+id).insertBefore display,document.querySelector '#'+id+'>g'

  uuid= ->
    # via http://stackoverflow.com/questions/105034/create-guid-uuid-in-javascript
    S4=-> (((1+Math.random())*0x10000)|0).toString(16).substring(1)
    S4()+S4()+"-"+S4()+"-"+S4()+"-"+S4()+"-"+S4()+S4()+S4()

class Jaggy.Frame# has many Color
  constructor:->
  putImageData:(begin,end,image,options={})->
    for key,value of this
      delete this[key] if this.hasOwnProperty key and key isnt 'attrs'

    return if image.data is undefined

    i= 0
    increment= if options.glitch then options.glitch else 4
    while (begin+i) <= end
      values= []
      # if @disposal is 3
      #   values.push image.data[i+0]
      #   values.push image.data[i+1]
      #   values.push image.data[i+2]
      #   values.push (image.data[i+3]/255).toFixed(2)

      if image.data[begin+i+3] isnt 0
        values= []
        values.push image.data[begin+i+0]
        values.push image.data[begin+i+1]
        values.push image.data[begin+i+2]
        values.push (image.data[begin+i+3]/255).toFixed(2)

      if values.length
        rgba= 'rgba('+values.join(',')+')'
        if this[rgba] is undefined
          this[rgba]= new Jaggy.Color

        x= (i/4)% image.width
        y= ~~((i/4)/image.width)
        this[rgba].put (new Jaggy.Point x,y)

      i= if typeof increment is 'function' then increment(i) else i+increment

  toG:->
    g= Jaggy.createElement 'g'
    for key,value of this
      g.setAttribute key,value if typeof value is 'number'
      g.appendChild value.toPath key if value instanceof Jaggy.Color
    g

class Jaggy.Color# has many Rect in @points
  constructor:(@points=[])->
  put:(point)-> @points.push point

  toPath:(fill='black')->
    dom= document ? require('dom-lite').document

    path= Jaggy.createElement 'path'
    path.setAttribute 'fill',fill if fill.length
    path.setAttribute 'd',@getRects().map((rect)->rect.toD()).join '' if @points.length
    path

  getRects:->
    rects= []

    # Merge @points for horizontal
    rect_index= {}# Merge to rect of over if equal x and width
    i= 0
    while i < @points.length
      point= @points[i++]

      left= rects[rects.length-1]|| {}
      is_left= left.y is point.y and (left.x+left.width) is point.x
      if is_left
        left.width++
        continue
      
      rect_index[left.x]?= {}
      rect_index[left.x][left.y]= left if left.width
      left_over= rect_index[left.x][left.y-1] || {}
      is_same_length= left.width is left_over.width and left_over.x isnt undefined
      if is_same_length
        left_over.height++# Glitch point...
        rect_index[left.x][left.y]= left_over
        rects.pop()
        i--
        continue

      rects.push point.toRect()

    rects

class Jaggy.Rect
  constructor:(point)->
    @x= point.x
    @y= point.y
    @width= 1
    @height= 1

  toD: ->
    # 1pixel = <path d='M0,0 h1 v1 h-1 z'>
    'M'+@x+','+@y+'h'+@width+'v'+@height+'h-'+@width+'Z';

class Jaggy.Point
  constructor:(@x,@y)->
  toRect:-> new Jaggy.Rect this

module.exports= Jaggy