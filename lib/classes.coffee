document= window?.document
if not window?
  document= require('dom-lite').document
  document.createElementNS= (ns,name)->
    element= document.createElement name
    element.setAttributeNS?= (ns,key,value)-> this.setAttribute key,value
    element

class Frames
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
      frame= new Frame
      frame.delay= image.anime.delays[i] if image.anime?
      frame.disposal= image.anime.disposals[i] if image.anime?
      frame.putImageData i*@frame_size,i*@frame_size+@frame_size,image,options
      @frames.push frame

      i++

  toSVG:->
    svg= document.createElementNS 'http://www.w3.org/2000/svg','svg'
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
    g= document.createElementNS 'http://www.w3.org/2000/svg','g'
    g.setAttribute 'style','display:none'
    g.appendChild frame.toG() for frame in @frames
    g

  createScript:(id)->
    script= document.createElement 'script'
    script.appendChild document.createTextNode "(#{animation.toString()})('#{id}');"
    script

  # private

  animation= (id)->
    i= 0
    frames= [].slice.call window.document.querySelectorAll '#'+id+'>g>g'
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
        uses= window.document.querySelectorAll '#'+id+'>use'
        use.parentNode.removeChild use for use in uses

      i++
      createDisplay frame_id
      setTimeout nextFrame,frame.getAttribute 'delay'

    createDisplay=(frame_id)->
      display= window.document.createElementNS 'http://www.w3.org/2000/svg','use'
      display.setAttributeNS 'http://www.w3.org/1999/xlink','href','#'+frame_id if frame_id

      anime= window.document.querySelector '#'+id
      anime.insertBefore display,window.document.querySelector '#'+id+'>g' if anime?

  uuid= ->
    # via http://stackoverflow.com/questions/105034/create-guid-uuid-in-javascript
    S4=-> (((1+Math.random())*0x10000)|0).toString(16).substring(1)
    S4()+S4()+"-"+S4()+"-"+S4()+"-"+S4()+"-"+S4()+S4()+S4()

class Frame# has many Color
  constructor:->
  putImageData:(begin,end,image,options={})->
    for key,value of this
      delete this[key] if this.hasOwnProperty key and key isnt 'attrs'

    return if image.data is undefined

    i= 0
    increment= if options.glitch? then options.glitch else 4
    while (begin+i) <= end
      opacity= image.data[begin+i+3] > 0 and image.data[begin+i+0]?
      if opacity
        values= []
        values.push image.data[begin+i+0]
        values.push image.data[begin+i+1]
        values.push image.data[begin+i+2]
        values.push (image.data[begin+i+3]/255).toFixed(2)

        x= (i/4)% image.width
        y= ~~((i/4)/image.width)
        
        rgba= 'rgba('+values.join(',')+')'
        @[rgba]= new Color if not @[rgba]?
        @[rgba].put (new Point x,y)

      i= if typeof increment is 'function' then increment(i) else i+increment

  toG:->
    g= document.createElementNS 'http://www.w3.org/2000/svg','g'
    for key,value of this
      g.setAttribute key,value if typeof value is 'number'
      g.appendChild value.toPath key if value instanceof Color
    g

class Color# has many Rect in @points
  constructor:(@points=[])->
  put:(point)-> @points.push point

  toPath:(fill='black')->
    path= document.createElementNS 'http://www.w3.org/2000/svg','path'
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

class Rect
  constructor:(point)->
    @x= point.x
    @y= point.y
    @width= 1
    @height= 1

  toD: ->
    # 1pixel = <path d='M0,0 h1 v1 h-1 z'>
    'M'+@x+','+@y+'h'+@width+'v'+@height+'h-'+@width+'Z';

class Point
  constructor:(@x,@y)->
  toRect:-> new Rect this

module.exports= {Frames, Frame, Color, Rect, Point}