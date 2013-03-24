#!/usr/bin/env lsc -cj
author: 'Chia-liang Kao'
name: 'ly.g0v.tw'
description: 'ly.g0v.tw'
version: '0.1.1'
homepage: 'https://github.com/g0v/ly.g0v.tw'
repository:
  type: 'git'
  url: 'https://github.com/g0v/ly.g0v.tw'
engines:
  node: '0.8.x'
  npm: '1.1.x'
scripts:
  prepublish: './node_modules/.bin/lsc -cj package.ls'
  start: './node_modules/.bin/brunch b --config brunch-templates.ls && ./node_modules/.bin/brunch watch --server'
  test: 'testacular test/testacular.config.js'
dependencies: {}
devDependencies:
  testacular: '>= 0.0.16'
  LiveScript: '1.1.x'
  brunch: '>= 1.4 < 1.5'
  'javascript-brunch': '>= 1.0 < 1.5'
  'LiveScript-brunch': '>= 1.0 < 1.5'
  'css-brunch': '>= 1.0 < 1.5'
  'sass-brunch': '>= 1.0 < 1.5'
  'jade-brunch': '>= 1.0 < 1.5'
  'static-jade-brunch': '>= 1.4.0 <= 1.4.5 || >= 1.4.8 < 1.5'
  'auto-reload-brunch': '>= 1.3 < 1.5'
  'uglify-js-brunch': '>= 1.0 < 1.5'
  'clean-css-brunch': '>= 1.0 < 1.5'
