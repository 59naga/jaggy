Jaggy= require './jaggy'

service= angular.module 'jaggy',[]
service.constant 'jaggy',window.jaggy.options

service.config (jaggy)->
  key= 'jaggy:version'
  value= '0.1.15'
  localStorage.clear() if localStorage.getItem(key) isnt value
  localStorage.setItem key,value

service.directive 'jaggy',(
  jaggy
)->
  (scope,element,attrs)->
    element.css 'display','none'

    scope.config= jaggy
    scope.$watch 'config',(-> createSVG()),yes

    createSVG= ->
      # fix <img ng-src="url" jaggy>
      url= attrs.src
      url?= attrs.ngSrc
      if not url? or url.length is 0
        if jaggy.emptySVG
          element.replaceWith Jaggy.emptySVG()
        return

      options= angular.copy jaggy
      if attrs.jaggy
        for param in attrs.jaggy.split ';'
          [key,value]= param.split ':'
          options[key]= value

      Jaggy.createSVG url,options,(error,svg)->
        svg= Jaggy.regenerateUUID svg if svg?
        svgElement= angular.element svg if svg?
        if error
          return element.css 'display',null if error is true # over pixelLimit
          throw error if not jaggy.emptySVG
          svgElement= angular.element Jaggy.emptySVG()
        element.replaceWith svgElement
        element= svgElement

        # fix animatedGif caching
        script= element.find 'script'
        eval script.html() if script?