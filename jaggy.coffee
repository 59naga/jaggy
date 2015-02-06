Jaggy= ->
  Jaggy.createSVG.apply null,arguments if typeof window isnt 'undefined'
  Jaggy.gulpPlugin.apply null,arguments if typeof window is 'undefined'

Jaggy.gulpPlugin= (options={})->
  gutil= require 'gulp-util'
  through2= require 'through2'
  return through2.obj (file,encode,next)->
    return @emit 'error',new gutil.PluginError 'jaggy','Streaming not supported' if file.isStream()

    Jaggy.readImageData file,(error,pixels)=>
      throw error if error?

      file.path= gutil.replaceExtension file.path,'.svg'
      file.contents= new Buffer Jaggy.convertToSVG pixels,options
      @push file

      next()

# Use url for browser
Jaggy.createSVG= (url,args...)->
  throw new Error 'url is not string' if typeof url isnt 'string'
  callback= null
  args.forEach (arg)-> switch typeof arg
    when 'function' then callback= arg
  
  getPixels= require 'get-pixels'
  getPixels url,(error,pixels)->
    return callback error if error?

    if pixels.shape.length is 3
      svg= Jaggy.convertToSVG pixels,outerHTML:false
      callback null,svg

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

        svg= Jaggy.convertToSVG pixels,outerHTML:false
        callback null,svg

Jaggy.convertToSVG= (pixels,options={})->
  jaggy= Jaggy.convert pixels,options

  svg= jaggy.toSVG options
  svg= options.afterConvert svg,jaggy,file if typeof options.afterConvert is 'function'

  if options.outerHTML isnt false
    svg= svg.outerHTML.replace ' viewbox=',' viewBox='# fix to lowerCamel
    svg= svg.replace(/&gt;/g,'>')# enable querySelector
    return svg

  svg

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
    svg= Jaggy.createElementNS 'svg'
    for key,value of @attrs
      svg.setAttribute key,value if key.indexOf('xmlns') is 0
      svg.setAttributeNS null,key,value if key.indexOf('xmlns') isnt 0
    if @frames.length is 1
      svg.appendChild @frames[0].toG()
    else
      svg.setAttribute 'id','A'+uuid()
      svg.appendChild @createAnime()
      svg.appendChild @createScript(svg.id)
    svg

  createAnime:->
    g= Jaggy.createElementNS 'g'
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
      frame= frames[i]
      frame= frames[i= 0] if frame is undefined
      frame_id= frame.getAttribute 'id'
      if frame_id is null
        frame_id= id+'_'+('0000'+i).slice(-5) 
        frame.setAttribute 'id',frame_id

      if i is 0
        uses= document.querySelectorAll '#'+id+'>use'
        use.parentNode.removeChild use for use in uses

      i++
      createDisplay frame_id
      setTimeout nextFrame,frame.getAttribute 'delay'

    createDisplay=(frame_id)->
      display= document.createElementNS 'http://www.w3.org/2000/svg','use'
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

        rgba= 'rgba('+values.join(',')+')'
        if this[rgba] is undefined
          this[rgba]= new Jaggy.Color

        x= (i/4)% image.width
        y= ~~((i/4)/image.width)
        this[rgba].put (new Jaggy.Point x,y)

      i= if typeof increment is 'function' then increment(i) else i+increment

  toG:->
    g= Jaggy.createElementNS 'g'
    for key,value of this
      g.setAttribute key,value if typeof value is 'number'
      g.appendChild value.toPath key if value instanceof Jaggy.Color
    g

class Jaggy.Color# has many Rect in @points
  constructor:(@points=[])->
  put:(point)-> @points.push point

  toPath:(fill='black')->
    path= Jaggy.createElementNS 'path'
    path.setAttributeNS null,'fill',fill if fill.length
    path.setAttributeNS null, 'd',@getRects().map((rect)->rect.toD()).join '' if @points.length
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

if typeof window isnt 'undefined'
  Jaggy.createElement= document.createElement.bind document
  Jaggy.createElementNS= document.createElementNS.bind document,'http://www.w3.org/2000/svg'
  Jaggy.createTextNode= document.createTextNode.bind document

  window.jaggy= Jaggy
else
  domlite= require('dom-lite').document
  Jaggy.createElement= domlite.createElement.bind domlite
  Jaggy.createElementNS= (name)->
    element= Jaggy.createElement name
    element.setAttributeNS?= (ns,key,value)-> this.setAttribute key,value
    element
  Jaggy.createTextNode= domlite.createTextNode.bind domlite

  module.exports= Jaggy if typeof window is 'undefined'