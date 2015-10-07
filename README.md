# ![jaggy][.svg] Jaggy [![NPM version][npm-image]][npm] [![Bower version][bower-image]][bower] [![Build Status][travis-image]][travis] [![Coverage Status][coveralls-image]][coveralls]

## for gulp
```bash
$ npm install gulp jaggy
```

gulpfile.js

```js
var jaggy,gulp;
jaggy= require('jaggy');
gulp= require('gulp');
gulp.task('default',function(){
  gulp.src(['*.png','*.gif','*.jpg'])
    .pipe(jaggy())
    .pipe(gulp.dest('./'))
  ;
});
```

```bash
$ gulp # Create the .svg
```

## for CLI
Can use jaggy command to folder or file.
Create the sameName.svg by [.gif, .jpg, .png]

Example:

```bash
$ npm install gulp jaggy --global
$ jaggy public_html --recursive
```

## for browser
```bash
$ bower install jaggy
```

```html
<head>
  <script src="bower_components/jaggy/sources/jaggy.browser.js"></script>
</head>
<body>
  <img src="pixel_art.gif" class="jaggy">
  <img src="pixel_art.jpg" class="jaggy">
  <img src="pixel_art.png" class="jaggy">
</body>
```

* Add `jaggy.browser.js` for `<head>`.
* Set `jaggy` class for `<img>`.
* Converting after `DOMContentLoaded`.

***Doesn't work [Cross-origin][1]***

[1]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Access_control_CORS

## for angular.js 1.*

```html
<head>
  <script src="bower_components/angular/angular.min.js"></script>
  <script src="bower_components/jaggy/public/jaggy.browser.js"></script>
  <script>angular.module('myApp',['jaggy'])</script>
</head>
<body ng-app="myApp">
  <img src="moon.png" jaggy alt=""> <!-- replaceWith <svg> -->
</body>
```

Can use `jaggy` directive.

## Why?
Doesn't work [`image-rendering:crisp-edges`](http://caniuse.com/#feat=css-crisp-edges).
However, Can work on the [`<svg shape-rendering="crispEdges">`](http://caniuse.com/#feat=svg).
Gotcha, save the jaggy.

## Browser options
### for browser
```js
<script>
  // default true
  jaggy.options.cache= false;

  // default: true
  jaggy.emptyImage= false;

  // default 0
  jaggy.options.pixelLimit= 128 * 128 * 4;

  // default 4
  jaggy.options.glitch= 3;
</script>
```
### for angular.js 1.*
```html
<script>
var app=angular.module('myApp',['jaggy']);
app.config(function(jaggy){
  //default: true
  jaggy.cache= false;

  //default: true
  jaggy.emptyImage= false;

  //default: 0
  jaggy.pixelLimit= 128 * 128 * 4;

  //default: 4
  jaggy.glitch= 3;
});
</script>
```

* `.cache`
    Caching a converted svg by localStorage.

* `.emptyImage`
    Replace empty image instead of Error. e.g. `<svg><path fill="rgba(0,0,0,0.50)"/>`

* `.pixelLimit`
    Skip a converting if over set value.

    ```html
    <!-- skip a below -->
    <script>
    var app=angular.module('myApp',['jaggy']);
    app.config(function(jaggy){
      jaggy.pixelLimit= 128 * 128 * 4 * 1;
    });
    </script>
    <body>
      <img src="huge_pixelart.png" jaggy>
      <img src="long_animation.gif" jaggy>
    </body>

    <!-- unlimited -->
    <script>
    var app=angular.module('myApp',['jaggy']);
    app.config(function(jaggy){
      jaggy.pixelLimit= 0;
    });
    </script>
    <!-- ... -->
    ```

    Default: 262144 (= width 256 * height 256 * channel 4 * frame 1)

* `.glitch`
    Change `Frame.putImageData` logic by increment channel value.

## Known issue
* Svg conversion of animated gif is experimental. It will take the high the CPU usage to play.
* Uncaught QuotaExceededError: Failed to execute 'setItem' on 'Storage': Setting the value of `jaggy:url` exceeded the quota. due to Huge Animationed gif

## TODO
* TEST for jaggy.browser.coffee
* TEST for jaggy.angular.coffee

License
=========================
[MIT][License] by 59naga

[License]: http://59naga.mit-license.org/

[.svg]: https://cdn.rawgit.com/59naga/jaggy/master/.svg?

[npm-image]: https://badge.fury.io/js/jaggy.svg
[npm]: https://npmjs.org/package/jaggy
[bower-image]: https://badge.fury.io/bo/jaggy.svg
[bower]: http://badge.fury.io/bo/jaggy
[travis-image]: https://travis-ci.org/59naga/jaggy.svg?branch=master
[travis]: https://travis-ci.org/59naga/jaggy
[coveralls-image]: https://coveralls.io/repos/59naga/jaggy/badge.svg?branch=master
[coveralls]: https://coveralls.io/r/59naga/jaggy?branch=master
