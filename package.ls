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
  prepublish: 'node ./node_modules/.bin/lsc -cj package.ls'
  start: 'node ./node_modules/.bin/brunch watch --server'
  test: 'testacular test/testacular.config.js'
dependencies: {}
devDependencies:
  testacular: '>= 0.6.x'
  LiveScript: '1.1.x'
  brunch: '1.6.x'
  'javascript-brunch': '1.5.x'
  'LiveScript-brunch': '1.5.x'
  'css-brunch': '1.5.x'
  'sass-brunch': '1.5.x'
  'jade-brunch': '1.5.x'
  'static-jade-brunch': '>= 1.4.8 < 1.5'
  'auto-reload-brunch': '1.5.x'
  'uglify-js-brunch': '1.5.x'
  'clean-css-brunch': '1.5.x'
