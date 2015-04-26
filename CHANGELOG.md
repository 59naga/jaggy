v0.1.17-rc.2 / Apr 26 2015
=========================
 * [`unknown`][13] :bug: Fix [#6][13A]
 * [`unknown`][13] :bug: Fix [#7][13B]

[13]: https://github.com/59naga/jaggy/commit/
[13A]: https://github.com/59naga/jaggy/issues/6
[13B]: https://github.com/59naga/jaggy/issues/7

v0.1.17 / Apr 15 2015
=========================
 * [`5078a94`][12] :racehorse: Add Jaggy.queues for Jaggy.createSVG
 * [`5078a94`][12] :lipstick: Move Jaggy.createSVG to Jaggy._createSVG
 * [`5078a94`][12] :racehorse: Add Jaggy.options.timeout for Jaggy._createSVG
 * [`5078a94`][12] :racehorse: Add lz-string for caching(setCache/getCache)

[12]: https://github.com/59naga/jaggy/commit/5078a9470f3026702a0fdf01a1e7a0d749d29dd5

v0.1.15 / Apr 12 2015
=========================
 * [`20c58d2`][9] :bulb: Add jaggy.pixelLimit for angular.js
 * [`bbc4132`][10] :fire: Deprecated `window.jaggy`. Move to `window.jaggy.createSVG`
 * [`bbc4132`][10] :lipstick: Rename for angular.js
     * jaggyConfig to `jaggy`
     * jaggyConfig.useCache to `jaggy.cache`
     * jaggyConfig.useEmptyImage to `jaggy.emptyImage`
 * [`bbc4132`][10] :bug: Fix duplicate uuid for animation
 * [`2fb60d9`][11] :bug: Fix InvalidCharacterError: DOM Exception 5 on safari

[9]: https://github.com/59naga/jaggy/commit/20c58d2ea152ce4481a634f35562ea7e2334e9fe
[10]: https://github.com/59naga/jaggy/commit/bbc413299f362e5e26d270b04237ddda61c21927
[11]: https://github.com/59naga/jaggy/commit/2fb60d9db8df447ac222385ae6274225c14747af

v0.1.13 / Apr 10 2015
=========================
 * [`8ea1129`][7] :bug: fix `Cannot read property 'indexOf' of undefined` by angular-jaggy
 * [`65b72fb`][8] :bulb: Add `jaggyConfig.glitch`

[7]: https://github.com/59naga/jaggy/commit/8ea1129a91043d569ef63ad3c1d46cd0eb07a8b0
[8]: https://github.com/59naga/jaggy/commit/65b72fbd4b8f16823bf6bddf46ee5c2b1b4b853b

v0.1.11 / Apr 8 2015
=========================
 * [`0265a98`][6] :bug: Hotfix [#3][6A]

[6A]: https://github.com/59naga/jaggy/issues/3
[6]: https://github.com/59naga/jaggy/commit/0265a98fd8f6d5270b7eaef60c559511335aeb38

v0.1.9 / Apr 7 2015
=========================
 * [`d36c425`][5] :lipstick: Add ng-annotate for uglifyjs

[5]: https://github.com/59naga/jaggy/commit/d36c425846abff547f719c43dc2ecf67097079e8

v0.1.8 / Mar 30 2015
=========================
Add Angular options by constant `jaggyConfig`

 * [`a907a0a`][2] :bulb: empty image instead of Error by `jaggyConfig.useEmptyImage`
 * [`a907a0a`][2] :bulb: caching a converted svg by `jaggyConfig.useCache`

 * [`unknown`][3] :bug: Fix [#1](https://github.com/59naga/jaggy/issues/1)
 * [`unknown`][4] :bug: Fix [#2](https://github.com/59naga/jaggy/issues/2)

[2]: https://github.com/59naga/jaggy/commit/a907a0a5da621d26fb5c01fceb49a882b6f97a71
[3]: https://github.com/59naga/jaggy/commit/d4cd748d68f2fd27b17af54cc768bc1cbb196d3d
[4]: https://github.com/59naga/jaggy/commit/4cb8d40a9ae223a97249f4d07fae390f3435c183

v0.1.4 / Mar 29 2015
=========================
 * [`21fb96a`][1] :bug: Fix `<path fill="rgba(,,,NaN)"`
 * [`21fb96a`][1] :lipstick: Support `<img ng-src="" jaggy>`

[1]: https://github.com/59naga/jaggy/commit/21fb96a22352c84f4802c50f6a35f7500cee9254

v0.1.3 / Mar 03 2015
=========================
 * [`1084961c`][0] Release v0.1.3

[0]: https://github.com/59naga/jaggy/commits/master