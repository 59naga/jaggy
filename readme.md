# Jaggy(options)
[![NPM version][npm-image]][npm]
[![Build Status][travis-image]][travis]
[![Dependency Status][depstat-image]][depstat]

```coffee
jaggy= require 'jaggy'
gulp.src 'fixtures/*.png'
  .pipe jaggy()
  .pipe gulp.dest 'public_html'
```

#### options.afterConvert: function
#### options.glitch: int or function (fragile)

## Feture
* ***TEST***
* Support Animation GIF
* Browser Friendly ([Like this](https://github.com/59naga/vectorizer/))
* Support `install -g`

# License
MIT by [@59naga](https://twitter.com/horse_n_deer)

[npm-image]: https://badge.fury.io/js/jaggy.svg
[npm]: https://npmjs.org/package/jaggy
[travis-image]: https://travis-ci.org/59naga/jaggy.svg?branch=master
[travis]: https://travis-ci.org/59naga/jaggy
[depstat-image]: https://gemnasium.com/59naga/jaggy.svg
[depstat]: https://gemnasium.com/59naga/jaggy
