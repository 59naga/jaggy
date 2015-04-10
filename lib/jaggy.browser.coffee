jaggy= require './jaggy'

getPixels= require 'get-pixels'
gifyParse= require 'gify-parse'

# Use url for browser
jaggy.createSVG= (url,args...)->
  callback= null
  options= {}
  args.forEach (arg)-> switch typeof arg
    when 'function' then callback= arg
    when 'object' then options= arg

  if options.cache
    options.cacheUrl= url
    cache= jaggy.getCache url
    return callback null,cache if cache? and not options.noCache?
  
  getPixels url,(error,pixels)->
    return callback error if error?
    return callback true if options.pixelLimit>0 and pixels.data.length> options.pixelLimit

    if pixels.shape.length is 3
      jaggy.convertToSVG pixels,options,callback

    if pixels.shape.length is 4
      xhr= new XMLHttpRequest
      xhr.open 'GET',url,true
      xhr.responseType= 'arraybuffer'
      xhr.send()
      xhr.onerror= -> callback xhr.statusText
      xhr.onload= ->
        anime= gifyParse.getInfo xhr.response
        anime.delays= anime.images.map (image)-> image.delay
        anime.disposals= anime.images.map (image)-> image.disposal
        pixels.anime= anime

        jaggy.convertToSVG pixels,options,callback

jaggy.getCache= (url)->
  localStorage.getItem 'jaggy:'+url
jaggy.setCache= (url,element,options={})->
  cacheElement= element.cloneNode true
  if options.cacheScript is 'base64'
    script= cacheElement.querySelector 'script'
    script.innerHTML= btoa script.innerHTML if script

  div= document.createElement 'div'
  div.appendChild cacheElement
  cache= div.innerHTML

  try
    localStorage.setItem 'jaggy:'+url,cache
  catch error
    localStorage.removeItem 'jaggy:'+url
    
    console.error 'jaggy:'+url,error

return if not angular?

service= angular.module 'jaggy',[]
service.constant 'jaggyEmptyImage','<svg viewBox="0 0 1 1" shape-rendering="crispEdges" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><path d="M0,0h1v1h-1Z" fill="rgba(0,0,0,0.50)"></path></svg>'
service.constant 'jaggyConfig',{
  useCache: 'localStorage'
  useEmptyImage: yes
  pixelLimit: 256*256*4+1
  glitch: 4
}
service.config (jaggyConfig)->
  key= 'jaggy:version'
  value= '0.1.13'
  localStorage.clear() if localStorage.getItem(key) isnt value
  localStorage.setItem key,value

service.directive 'jaggy',(
  jaggyConfig
  jaggyEmptyImage
)->
  (scope,element,attrs)->
    element.css 'display','none'

    options= angular.copy jaggyConfig
    options.cache= !! jaggyConfig.useCache
    options.cacheScript?= 'base64'
    if attrs.jaggy
      for param in attrs.jaggy.split ';'
        [key,value]= param.split ':'
        options[key]= value

    # fix <img ng-src="url" jaggy>
    url= attrs.src
    url?= attrs.ngSrc
    if not url? or url.length is 0
      element.replaceWith jaggyEmptyImage if jaggyConfig.useEmptyImage 
      return

    scope.config= jaggyConfig
    scope.$watch 'config',(next,prev)->
      if next.glitch>0
        options.glitch= next.glitch
        options.cache= no if next.glitch isnt prev.glitch
        convert()
    ,yes

    convert= ->
      jaggy.createSVG url,options,(error,svg)->
        svgElement= angular.element svg if svg?
        if error
          return element.css 'display',null if error is true # over pixelLimit
          throw error if not jaggyConfig.useEmptyImage
          svgElement= angular.element jaggyEmptyImage
        element.replaceWith svgElement
        element= svgElement

        # fix animatedGif caching
        if svg?.match and svg.match '<script>'
          svgContainer= document.createElement 'div'
          svgContainer.innerHTML= svg
          script= svgContainer.querySelector('script')?.innerHTML or ''
          script= atob script if options.cacheScript is 'base64'
          eval script

window.jaggy= jaggy.createSVG