gulp = require 'gulp'
gutil = require 'gulp-util'
autowatch = require 'gulp-autowatch'
browserify = require 'gulp-browserify'
changed = require 'gulp-changed'
coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
nodemon = require 'gulp-nodemon'
plumber = require 'gulp-plumber'

paths =
  coffee: 'src/**/*.coffee'
  client: 'src/client/**/*.coffee'
  assets: 'assets/**'

gulp.task 'coffee', ->
  gulp.src paths.coffee
  .pipe changed 'lib'
  .pipe plumber()
  .pipe coffee()
  .on 'error', gutil.log
  .pipe gulp.dest 'lib'

gulp.task 'client', ->
  gulp.src 'src/client/index.coffee',
    read: false
  .pipe plumber()
  .pipe browserify
    transform: ['coffeeify']
    extensions: ['.coffee']
  .on 'error', gutil.log
  .pipe concat 'script/index.js'
  .pipe gulp.dest 'public'

gulp.task 'assets', ->
  gulp.src paths.assets
  .pipe gulp.dest 'public'

gulp.task 'serve', ['watch'], (cb) ->
  started = false
  nodemon
    watch: ['lib', '!lib/client/**']
    ignore: ['lib/client/**']
    script: 'lib/index.js'
  .on 'start', ->
    return if started
    started = true
    cb()

gulp.task 'watch', Object.keys(paths), ->
  autowatch gulp, paths

gulp.task 'default', ['coffee', 'client', 'assets']
