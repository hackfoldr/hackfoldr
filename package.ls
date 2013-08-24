#!/usr/bin/env lsc -cj
author: 'Chia-liang Kao'
name: 'hackfoldr'
description: 'hackfoldr'
version: '0.1.1'
homepage: 'https://github.com/hackfoldr/hackfoldr'
repository:
  type: 'git'
  url: 'https://github.com/hackfoldr/hackfoldr'
engines:
  node: '0.8.x'
  npm: '1.1.x'
scripts:
  prepublish: """
    node ./node_modules/LiveScript/bin/lsc -cj package.ls
    node ./node_modules/LiveScript/bin/lsc -c karma.conf.js.ls
  """
  start: 'node ./node_modules/brunch/bin/brunch watch --server'
  test: './node_modules/.bin/karma start --single-run --browsers PhantomJS'
dependencies: {}
devDependencies:
  LiveScript: '1.1.x'
  brunch: '1.6.x'
  'javascript-brunch': '1.5.x'
  'LiveScript-brunch': '1.5.x'
  'css-brunch': '1.5.x'
  'sass-brunch': '1.5.x'
  'jade-brunch': '1.5.x'
  'static-jade-brunch': '>= 1.4.8 < 1.5'
  'auto-reload-brunch': '1.6.x'
  'uglify-js-brunch': '1.5.x'
  'clean-css-brunch': '1.5.x'
  'jade-angularjs-brunch': '0.0.5'
  'jsenv-brunch': '1.4.2'
  karma: '~0.9.3'
  'karma-live-preprocessor': '~0.1.0'
  'karma-mocha': '~0.1.0'
