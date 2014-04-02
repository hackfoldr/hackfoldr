paths =
  pub: '_public'
  static: 'app/index.static.jade'
  template: 'app/partials/**/*.jade'
  assets: 'app/assets/**'
  js-vendor: 'vendor/scripts/*.js'
  js-env: 'app/*.jsenv'
  ls-app: 'app/**/*.ls'
  css-vendor: 'vendor/styles/*.css'
  stylus: 'app/styles/*.styl'

require! <[gulp gulp-util gulp-concat gulp-livescript gulp-livereload streamqueue]>
gutil = gulp-util

livereload-server = require(\tiny-lr)!
livereload = -> gulp-livereload livereload-server

require! <[express path]>
gulp.task \httpServer ->
  port = 3333
  app = require('express')!
  app.use require('connect-livereload')!
  app.use express.static path.resolve paths.pub
  app.all '/**' (req, res, next) ->
    res.sendfile __dirname + '/_public/index.html'
  http-server = require \http .create-server app
  http-server.listen port, ->
    gutil.log "Running on http://localhost:#port"

gulp.task 'build' <[static assets template js:app js:vendor css]>
gulp.task 'dev' <[build httpServer]> ->
  port = 35729
  livereload-server.listen port, -> gutil.log it if it
  gulp.watch paths.static, <[static]>
  gulp.watch paths.template, <[template]>
  gulp.watch paths.assets, <[assets]>
  gulp.watch [paths.js-env, paths.ls-app] <[js:app]>
  gulp.watch paths.stylus, <[css]>

require! <[gulp-json-editor gulp-insert gulp-commonjs gulp-uglify]>
gulp.task 'js:app' ->
  env = gulp.src paths.js-env
    .pipe gulp-json-editor (json) ->
      for key of json when process.env[key]?
        json[key] = that
      json
    .pipe gulp-insert.prepend 'module.exports = '
    .pipe gulp-commonjs!

  app = gulp.src paths.ls-app
    .pipe gulp-livescript({+bare}).on \error gutil.log

  s = streamqueue { +objectMode }
    .done env, app
    .pipe gulp-concat 'app.js'
  s .= pipe gulp-uglify! if gutil.env.env is \production
  s .pipe gulp.dest "#{paths.pub}/js"

require! <[gulp-filter gulp-bower gulp-bower-files gulp-stylus gulp-cssmin]>
gulp.task 'bower' -> gulp-bower!

gulp.task 'js:vendor' <[bower]> ->
  bower = gulp-bower-files!
    .pipe gulp-filter (.path is /\.js$/)

  s = streamqueue { +objectMode }
    .done bower, gulp.src paths.js-vendor
    .pipe gulp-concat 'vendor.js'
  s .= pipe gulp-uglify! if gutil.env.env is \production
  s .pipe gulp.dest "#{paths.pub}/js"
    .pipe livereload!

gulp.task 'css' <[bower]> ->
  vendor = gulp.src paths.css-vendor

  bower = gulp-bower-files!
    .pipe gulp-filter (.path is /\.css$/)

  bower-styl = gulp-bower-files!
    .pipe gulp-filter (.path is /\.styl$/)
    .pipe gulp-stylus use: <[nib]>

  styl = gulp.src paths.stylus
    .pipe gulp-filter (.path isnt /\/_[^/]+\.styl$/) # isnt files for including
    .pipe gulp-stylus use: <[nib]>

  s = streamqueue { +objectMode }
    .done vendor, bower, bower-styl, styl
    .pipe gulp-concat 'app.css'
  s .= pipe gulp-cssmin! if gutil.env.env is \production
  s .pipe gulp.dest "#{paths.pub}/css"
    .pipe livereload!

require! <[gulp-angular-templatecache gulp-jade]>
gulp.task 'static' ->
  gulp.src paths.static
    .pipe gulp-jade do
      pretty: yes
      locals:
        googleAnalytics: 'UA-39804485-1'
    .pipe gulp-concat 'index.html'
    .pipe gulp.dest paths.pub

gulp.task 'template' ->
  gulp.src paths.template
    .pipe gulp-jade!
    .pipe gulp-angular-templatecache 'partials.js' do
      base: "#{process.cwd!}/app"
      filename: 'partials.js'
      module: 'partials'
      standalone: true
    .pipe gulp.dest "#{paths.pub}/js"
    .pipe livereload!

gulp.task 'assets' ->
  gulp.src paths.assets
    .pipe gulp.dest paths.pub
