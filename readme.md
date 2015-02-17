# Jaggy [![NPM version][npm-image]][npm] [![Build Status][travis-image]][travis] [![Dependency Status][depstat-image]][depstat]

## for gulp
```bash
$ npm install jaggy gulp
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
$ gulp # convert to .svg
```

## for browser
```bash
$ bower install jaggy
```

```html
<script src="bower_components/jaggy/sources/jaggy.browser.js"></script>
<script>
  jaggy('your_pixelart.png',function(error,svg){
    console.log(svg);//object: <svg version="1.1" ...>...</svg>
  });
</script>
```
***Doesn't work [Cross-origin][1]***

[1]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Access_control_CORS

## for angular.js
```html
<head>
  <script src="bower_components/angular/angular.min.js"></script>
  <script src="bower_components/jaggy/sources/jaggy.browser.js"></script>
  <script>angular.module('myApp',['jaggy'])</script>
</head>
<body ng-app="myApp">
  <img src="moon.png" jaggy alt=""> <!-- replaceWith <svg> -->
</body>
```

## CLI
```bash
$ npm install jaggy -g
$ jaggy public_html
```

## Why?
Doesn't work [`image-rendering:crisp-edges`](http://caniuse.com/#feat=css-crisp-edges).
However, Can work on the [`<svg shape-rendering="crispEdges">`](http://caniuse.com/#feat=svg).
Gotcha, save the jaggy.

## Glitch option
`{glitch:int}`
### for gulp
```js
.pipe(jaggy({glitch:1}))
```
### for browser
```js
jaggy('your_pixelart.png',{glitch:2},function(error,svg){
```
### for angular.js
```html
<img src="your_pixelart.gif" jaggy="glitch:3" alt="">
```
### CLI
```bash
jaggy public_html -g 2
```

# License
MIT by [@59naga](https://twitter.com/horse_n_deer)

[npm-image]: https://badge.fury.io/js/jaggy.svg
[npm]: https://npmjs.org/package/jaggy
[travis-image]: https://travis-ci.org/59naga/jaggy.svg?branch=master
[travis]: https://travis-ci.org/59naga/jaggy
[depstat-image]: https://gemnasium.com/59naga/jaggy.svg
[depstat]: https://gemnasium.com/59naga/jaggy
