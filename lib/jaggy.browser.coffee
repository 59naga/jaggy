# Dependencies
Jaggy= require './jaggy'
Jaggy.options= 
  cache: yes
  cacheScript: 'base64'
  emptySVG: yes
  pixelLimit: 0
  timeout: 0
  glitch: 4
  debug: off

Frames= (require './classes').Frames

getPixels= require 'get-pixels'
gifyParse= require 'gify-parse'
LZString= require 'lz-string'

# Methods for browser
Jaggy.createSVG= (img,args...,callback)->
  beginQueue= not Jaggy.queues?
  requestAnimationFrame ->
    Jaggy.nextQueue() if beginQueue

  if not Jaggy.queues?
    Jaggy.queues= []
    Jaggy.begin= Date.now()
    console.log 'jaggy:createSVG','start' if Jaggy.options.debug

  queues= Jaggy.queues
  queues.push arguments
Jaggy.nextQueue= ->
  queue= Jaggy.queues.shift()
  if not queue?
    console.log 'jaggy:createSVG','successfully',(Date.now()- Jaggy.begin).toLocaleString(),'msec' if Jaggy.options.debug
    return Jaggy.queues= null

  [img,args...,callback]= queue
  options= args[0] or {}
  Jaggy._createSVG img,options,->
    callback arguments...

    Jaggy.nextQueue()

Jaggy._createSVG= (img,args...,callback)->
  url= img.getAttribute 'src' if img.getAttribute?
  url?= img
  options= args[0] or {}
  cacheUrl= url+options.glitch

  if options.cache
    begin= Date.now()
    cache= Jaggy.getCache cacheUrl,options
    console.log 'jaggy:cached',cacheUrl,cache.innerHTML.length.toLocaleString(),'decompressed',Date.now()-begin,'msec' if Jaggy.options.debug and cache?
    return callback null,cache if cache? and options.cache
  
  getPixels url,(error,pixels)->
    return callback error,null if error?
    return callback true,null if options.pixelLimit>0 and pixels.data.length> options.pixelLimit

    if pixels.shape.length is 3
      begin= Date.now()
      Jaggy.convertToSVG pixels,options,(error,svg)->
        Jaggy.setCache cacheUrl,svg,options if options.cache
        console.log 'jaggy:converted',cacheUrl,Date.now()-begin,'msec' if Jaggy.options.debug
        console.log 'jaggy:rendered',cacheUrl,svg.innerHTML.length.toLocaleString() if Jaggy.options.debug
        callback error,svg

    if pixels.shape.length is 4
      xhr= new XMLHttpRequest
      xhr.open 'GET',url,true
      xhr.timeout= Jaggy.options.timeout
      xhr.responseType= 'arraybuffer'
      xhr.send()
      xhr.onerror= -> callback xhr.statusText,null
      xhr.onload= ->
        anime= gifyParse.getInfo xhr.response
        anime.delays= anime.images.map (image)-> image.delay
        anime.disposals= anime.images.map (image)-> image.disposal
        pixels.anime= anime

        begin= Date.now()
        Jaggy.convertToSVG pixels,options,(error,svg)->
          Jaggy.setCache cacheUrl,svg,options if options.cache
          console.log 'jaggy:converted',cacheUrl,Date.now()-begin,'msec' if Jaggy.options.debug
          console.log 'jaggy:rendered',cacheUrl,svg.innerHTML.length.toLocaleString() if Jaggy.options.debug
          callback error,svg

Jaggy.flush= ()->
  for key in Object.keys localStorage
    localStorage.removeItem key if key.indexOf 'jaggy' is 0
  'flushed'

Jaggy.getCache= (url,options={})->
  div= document.createElement 'div'
  div.innerHTML= LZString.decompressFromBase64 localStorage.getItem 'jaggy:'+url

  # Decoding via localStorage
  if options.cacheScript is 'base64'
    script= div.querySelector 'script'
    if script
      enableScript= document.createElement 'script'
      enableScript.innerHTML= atob div.innerHTML.match('<script>(.*?)</script>')[1]
      script.parentNode.replaceChild enableScript,script

  div.querySelector 'svg'

Jaggy.setCache= (url,element,options={})->
  div= document.createElement 'div'
  div.appendChild element.cloneNode true
  if options.cacheScript is 'base64'
    script= div.querySelector 'script'
    script.innerHTML= btoa script.innerHTML if script

  cache= div.innerHTML

  # Maybe error due to capacity 10MB
  try
    compressed= LZString.compressToBase64 cache
    if Jaggy.options.debug
      console.log 'jaggy:compressed',url,~~((cache.length-compressed.length)/cache.length*100)+'%',cache.length.toLocaleString(),'->',compressed.length.toLocaleString()
    localStorage.setItem 'jaggy:'+url,compressed
  catch error
    localStorage.removeItem 'jaggy:'+url
    
    console.error 'jaggy:'+url,cache.length,error

Jaggy.replaceByClass= ->
  imgs= document.querySelectorAll '.jaggy'

  queues= []
  for img,i in imgs
    do (img,i)->
      next= ->
        queues[i+1]() if queues[i+1]?
        delete queues[i+1]
      queues.push ->
        Jaggy.createSVG img,Jaggy.options,(error,svg)->
          return if error is yes # pixelLimit
          # console.error error if error?

          svg= Jaggy.regenerateUUID svg if not error?
          svg= Jaggy.emptySVG() if error? and Jaggy.options.emptySVG
          img.parentNode.replaceChild svg,img
          next()

  queues[0]() if queues[0]?

Jaggy.regenerateUUID= (svg)->
  script= svg.querySelector 'script'
  if script?
    uuid= 'A'+Frames::uuid()

    id= svg.getAttribute 'id'
    svg.setAttribute 'id',uuid

    script.innerHTML= script.innerHTML.replace id,uuid if script

  svg

Jaggy.emptySVG= ->
  div= document.createElement 'div'
  div.innerHTML= '<svg viewBox="0 0 1 1" shape-rendering="crispEdges" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><path d="M0,0h1v1h-1Z" fill="rgba(0,0,0,0.50)"></path></svg>'
  div.querySelector 'svg'

window.jaggy= Jaggy
window.addEventListener 'DOMContentLoaded',->
  Jaggy.replaceByClass()

require './jaggy.angular' if window.angular?