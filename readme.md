# Jaggy
[![NPM version][npm-image]][npm]
[![Build Status][travis-image]][travis]
[![Dependency Status][depstat-image]][depstat]

## Use for gulp
```coffee
jaggy= require 'jaggy'
gulp.src ['fixtures/*.png','fixtures/*.gif','fixtures/*.jpg']
  .pipe jaggy()
  .pipe gulp.dest 'public_html'
```

## Use for browser
```html
<script src="/src/jaggy.browser.js"></script>
<script>
  jaggy('moon.png',function(error,svg){
    console.log(svg);//object: <svg version="1.1" ...>...</svg>
  });
</script>
```
***Doesn't work `file:///` schema***

## Why?
Doesn't work [`image-rendering:crisp-edges`](http://caniuse.com/#feat=css-crisp-edges).
However, Can work on the [`<svg shape-rendering="crispEdges">`](http://caniuse.com/#feat=svg).
Gotcha, save the jaggy.

## Feture
* ***TEST***
* <del>Support Animation GIF</del> <ins>unstable</ins>
* <del>Browser Friendly ([Like this](https://github.com/59naga/vectorizer/))</del>
* Support `install -g`

# License
MIT by [@59naga](https://twitter.com/horse_n_deer)

[npm-image]: https://badge.fury.io/js/jaggy.svg
[npm]: https://npmjs.org/package/jaggy
[travis-image]: https://travis-ci.org/59naga/jaggy.svg?branch=master
[travis]: https://travis-ci.org/59naga/jaggy
[depstat-image]: https://gemnasium.com/59naga/jaggy.svg
[depstat]: https://gemnasium.com/59naga/jaggy
