require! <[gulp gulp-util gulp-concat gulp-livescript gulp-livereload streamqueue]>
gutil = gulp-util

livereload-server = require(\tiny-lr)!
livereload = -> gulp-livereload livereload-server

gulp.task 'dev' <[js:app js:vendor css]>

require! <[gulp-json-editor gulp-insert gulp-commonjs gulp-uglify]>
gulp.task 'js:app' ->
  env = gulp.src 'app/*.jsenv'
    .pipe gulp-json-editor (json) ->
      for key of json when process.env[key]?
        json[key] = that
      json
    .pipe gulp-insert.prepend 'module.exports = '
    .pipe gulp-commonjs!

  app = gulp.src 'app/**/*.ls'
    .pipe gulp-livescript({+bare}).on \error gutil.log

  s = streamqueue { +objectMode }
    .done env, app
    .pipe gulp-concat 'app.js'
  s .= pipe gulp-uglify! if gutil.env.env is \production
  s .pipe gulp.dest '_public/js'

require! <[gulp-filter gulp-bower gulp-bower-files gulp-stylus gulp-cssmin]>
gulp.task 'bower' -> gulp-bower!

gulp.task 'js:vendor' <[bower]> ->
  #bower = gulp-bower-files!
  #  .pipe gulp-filter (.path is /\.js$/)

  s = streamqueue { +objectMode }
    .done /*bower, */gulp.src 'vendor/scripts/*.js'
    .pipe gulp-concat 'vendor.js'
  s .= pipe gulp-uglify! if gutil.env.env is \production
  s .pipe gulp.dest '_public/js'
    .pipe livereload!

gulp.task 'css' <[bower]> ->
  #bower = gulp-bower-files!
  #  .pipe gulp-filter (.path is /\.css$/)

  bower-styl = gulp-bower-files!
    .pipe gulp-filter ->
      console.log it.path
      it.path is /\.styl$/
    .pipe gulp-stylus use: <[nib]>

  styl = gulp.src 'app/styles/**/*.styl'
    .pipe gulp-filter (.path isnt /\/_[^/]+\.styl$/) # isnt files for including
    .pipe gulp-stylus use: <[nib]>

  s = streamqueue { +objectMode }
    .done /*bower, */bower-styl, styl, gulp.src 'app/styles/**/*.css'
    .pipe gulp-concat 'app.css'
  s .= pipe gulp-cssmin! if gutil.env.env is \production
  s .pipe gulp.dest './_public/css'
    .pipe livereload!
