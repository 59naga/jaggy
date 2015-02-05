// Generated by CoffeeScript 1.9.0
var Jaggy, describe, _ref, _ref1,
  __slice = [].slice;

Jaggy = function() {
  var args, options;
  options = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
  if (args.length === 0) {
    return Jaggy.gulpPlugin(options);
  }
};

describe = (require('debug'))('jaggy');

Jaggy.createElement = (_ref = typeof document !== "undefined" && document !== null ? document.createElement : void 0) != null ? _ref : require('dom-lite').document.createElement.bind(require('dom-lite').document);

Jaggy.createTextNode = (_ref1 = typeof document !== "undefined" && document !== null ? document.createTextNode : void 0) != null ? _ref1 : require('dom-lite').document.createTextNode.bind(require('dom-lite').document);

Jaggy.gulpPlugin = function(options) {
  var gutil, through2;
  if (options == null) {
    options = {};
  }
  gutil = require('gulp-util');
  through2 = require('through2');
  return through2.obj(function(file, encode, next) {
    if (file.isStream()) {
      return this.emit('error', new gutil.PluginError('jaggy', 'Streaming not supported'));
    }
    describe('Convert to pixelArray by Image');
    return Jaggy.readImageData(file, (function(_this) {
      return function(error, pixels) {
        var html, jaggy, svg;
        if (error != null) {
          throw error;
        }
        describe('Convert to Frame by pixelArray');
        jaggy = Jaggy.convert(pixels, options);
        describe('Create <svg> by Frame');
        svg = jaggy.toSVG(options);
        if (typeof options.afterConvert === 'function') {
          svg = options.afterConvert(svg, jaggy, file);
        }
        html = svg.outerHTML.replace(' viewbox=', ' viewBox=');
        html = html.replace(/&gt;/g, '>');
        file.path = gutil.replaceExtension(file.path, '.svg');
        file.contents = new Buffer(html);
        _this.push(file);
        return next();
      };
    })(this));
  });
};

Jaggy.readImageData = function(file, callback) {
  var buffer, getPixels, mime, mimeType;
  if (typeof file !== 'object') {
    return callback('file is not object');
  }
  buffer = new Buffer(file.contents);
  mime = require('mime');
  mimeType = mime.lookup(file.path);
  getPixels = require('get-pixels');
  return getPixels(buffer, mimeType, function(error, pixels) {
    var anime, gifyParse;
    if (error != null) {
      return callback(error);
    }
    if (pixels.shape.length === 4) {
      gifyParse = require('gify-parse');
      anime = gifyParse.getInfo(buffer);
      anime.delays = anime.images.map(function(image) {
        return image.delay;
      });
      anime.disposals = anime.images.map(function(image) {
        return image.disposal;
      });
      pixels.anime = anime;
    }
    return callback(null, pixels);
  });
};

Jaggy.convert = function(pixels, options) {
  var channel, frame, height, width, _ref2, _ref3, _ref4;
  if (options == null) {
    options = {};
  }
  if ((pixels != null ? (_ref2 = pixels.shape) != null ? _ref2.length : void 0 : void 0) === void 0) {
    throw new Error('Not supported File');
  }
  if (pixels.shape.length === 3) {
    _ref3 = pixels.shape, width = _ref3[0], height = _ref3[1], channel = _ref3[2];
  }
  if (pixels.shape.length === 4) {
    _ref4 = pixels.shape, frame = _ref4[0], width = _ref4[1], height = _ref4[2], channel = _ref4[3];
  }
  pixels.frame = frame != null ? frame : 1;
  pixels.width = width;
  pixels.height = height;
  pixels.channel = channel;
  return new Jaggy.Frames(pixels, options);
};

Jaggy.Frames = (function() {
  var animation, uuid;

  function Frames(image, options) {
    var frame, i;
    if (options == null) {
      options = {};
    }
    this.attrs = {
      'version': '1.1',
      'xmlns': 'http://www.w3.org/2000/svg',
      'xmlns:xlink': 'http://www.w3.org/1999/xlink',
      'shape-rendering': 'crispEdges',
      'width': image.width,
      'height': image.height,
      'viewBox': "0 0 " + image.width + " " + image.height
    };
    this.frame_size = image.width * image.height * image.channel;
    this.frames = [];
    this.delays = image.anime || [];
    i = 0;
    while (image.data[i * this.frame_size] !== void 0) {
      frame = new Jaggy.Frame;
      if (image.anime != null) {
        frame.delay = image.anime.delays[i];
      }
      if (image.anime != null) {
        frame.disposal = image.anime.disposals[i];
      }
      frame.putImageData(i * this.frame_size, i * this.frame_size + this.frame_size, image, options);
      this.frames.push(frame);
      i++;
    }
  }

  Frames.prototype.toSVG = function() {
    var key, svg, value, _ref2;
    svg = Jaggy.createElement('svg');
    _ref2 = this.attrs;
    for (key in _ref2) {
      value = _ref2[key];
      svg.setAttribute(key, value);
    }
    if (this.frames.length === 1) {
      svg.appendChild(this.frames[0].toG());
    } else {
      svg.setAttribute('id', 'A' + uuid());
      svg.appendChild(this.createAnime());
      svg.appendChild(this.createScript(svg.id));
    }
    return svg;
  };

  Frames.prototype.createAnime = function() {
    var frame, g, _i, _len, _ref2;
    g = Jaggy.createElement('g');
    g.setAttribute('style', 'display:none');
    _ref2 = this.frames;
    for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
      frame = _ref2[_i];
      g.appendChild(frame.toG());
    }
    return g;
  };

  Frames.prototype.createScript = function(id) {
    var script;
    script = Jaggy.createElement('script');
    script.appendChild(Jaggy.createTextNode("(" + (animation.toString()) + ")('" + id + "');"));
    return script;
  };

  animation = function(id) {
    var createDisplay, display, frames, i, nextFrame;
    i = 0;
    frames = [].slice.call(document.querySelectorAll('#' + id + '>g>g'));
    display = null;
    setTimeout(function() {
      return nextFrame();
    });
    nextFrame = function() {
      var frame, frame_id, use, uses, _i, _len;
      frame = frames[i++];
      if (frame === void 0) {
        frame = frames[i = 0];
      }
      frame_id = frame.getAttribute('id');
      if (frame_id === null) {
        frame_id = id + '_' + ('0000' + i).slice(-5);
        frame.setAttribute('id', frame_id);
      }
      if (i === 0) {
        uses = document.querySelectorAll('#' + id + '>use');
        for (_i = 0, _len = uses.length; _i < _len; _i++) {
          use = uses[_i];
          use.parentNode.removeChild(use);
        }
      }
      createDisplay(frame_id);
      return setTimeout(nextFrame, frame.getAttribute('delay'));
    };
    return createDisplay = function(frame_id) {
      display = document.createElementNS('http://www.w3.org/2000/svg', 'use');
      display.setAttribute('xmlns:xlink', 'http://www.w3.org/1999/xlink');
      if (frame_id) {
        display.setAttributeNS('http://www.w3.org/1999/xlink', 'href', '#' + frame_id);
      }
      return document.querySelector('#' + id).insertBefore(display, document.querySelector('#' + id + '>g'));
    };
  };

  uuid = function() {
    var S4;
    S4 = function() {
      return (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1);
    };
    return S4() + S4() + "-" + S4() + "-" + S4() + "-" + S4() + "-" + S4() + S4() + S4();
  };

  return Frames;

})();

Jaggy.Frame = (function() {
  function Frame() {}

  Frame.prototype.putImageData = function(begin, end, image, options) {
    var i, increment, key, rgba, value, values, x, y, _results;
    if (options == null) {
      options = {};
    }
    for (key in this) {
      value = this[key];
      if (this.hasOwnProperty(key && key !== 'attrs')) {
        delete this[key];
      }
    }
    if (image.data === void 0) {
      return;
    }
    i = 0;
    increment = options.glitch ? options.glitch : 4;
    _results = [];
    while ((begin + i) <= end) {
      values = [];
      if (image.data[begin + i + 3] !== 0) {
        values = [];
        values.push(image.data[begin + i + 0]);
        values.push(image.data[begin + i + 1]);
        values.push(image.data[begin + i + 2]);
        values.push((image.data[begin + i + 3] / 255).toFixed(2));
      }
      if (values.length) {
        rgba = 'rgba(' + values.join(',') + ')';
        if (this[rgba] === void 0) {
          this[rgba] = new Jaggy.Color;
        }
        x = (i / 4) % image.width;
        y = ~~((i / 4) / image.width);
        this[rgba].put(new Jaggy.Point(x, y));
      }
      _results.push(i = typeof increment === 'function' ? increment(i) : i + increment);
    }
    return _results;
  };

  Frame.prototype.toG = function() {
    var g, key, value;
    g = Jaggy.createElement('g');
    for (key in this) {
      value = this[key];
      if (typeof value === 'number') {
        g.setAttribute(key, value);
      }
      if (value instanceof Jaggy.Color) {
        g.appendChild(value.toPath(key));
      }
    }
    return g;
  };

  return Frame;

})();

Jaggy.Color = (function() {
  function Color(_at_points) {
    this.points = _at_points != null ? _at_points : [];
  }

  Color.prototype.put = function(point) {
    return this.points.push(point);
  };

  Color.prototype.toPath = function(fill) {
    var dom, path;
    if (fill == null) {
      fill = 'black';
    }
    dom = typeof document !== "undefined" && document !== null ? document : require('dom-lite').document;
    path = Jaggy.createElement('path');
    if (fill.length) {
      path.setAttribute('fill', fill);
    }
    if (this.points.length) {
      path.setAttribute('d', this.getRects().map(function(rect) {
        return rect.toD();
      }).join(''));
    }
    return path;
  };

  Color.prototype.getRects = function() {
    var i, is_left, is_same_length, left, left_over, point, rect_index, rects, _name;
    rects = [];
    rect_index = {};
    i = 0;
    while (i < this.points.length) {
      point = this.points[i++];
      left = rects[rects.length - 1] || {};
      is_left = left.y === point.y && (left.x + left.width) === point.x;
      if (is_left) {
        left.width++;
        continue;
      }
      if (rect_index[_name = left.x] == null) {
        rect_index[_name] = {};
      }
      if (left.width) {
        rect_index[left.x][left.y] = left;
      }
      left_over = rect_index[left.x][left.y - 1] || {};
      is_same_length = left.width === left_over.width && left_over.x !== void 0;
      if (is_same_length) {
        left_over.height++;
        rect_index[left.x][left.y] = left_over;
        rects.pop();
        i--;
        continue;
      }
      rects.push(point.toRect());
    }
    return rects;
  };

  return Color;

})();

Jaggy.Rect = (function() {
  function Rect(point) {
    this.x = point.x;
    this.y = point.y;
    this.width = 1;
    this.height = 1;
  }

  Rect.prototype.toD = function() {
    return 'M' + this.x + ',' + this.y + 'h' + this.width + 'v' + this.height + 'h-' + this.width + 'Z';
  };

  return Rect;

})();

Jaggy.Point = (function() {
  function Point(_at_x, _at_y) {
    this.x = _at_x;
    this.y = _at_y;
  }

  Point.prototype.toRect = function() {
    return new Jaggy.Rect(this);
  };

  return Point;

})();

module.exports = Jaggy;
