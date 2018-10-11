gulp = require 'gulp'
connect = require 'gulp-connect'
concat = require 'gulp-concat'
uglify = require 'gulp-uglify'
process = require 'child_process'
purescript = require 'gulp-purescript'
browserify = require 'browserify'
source = require 'vinyl-source-stream'
buffer = require 'vinyl-buffer'

src   = './src/'
build = './build/'

html_src = "#{src}**/*.html"
sass_src = "#{src}sass/**/*.scss"
asset_src = "#{src}assets/**/*"
purs_src = [
  "src/**/*.purs",
  "../purescript-node-readline/src/**/*.purs",
  ".psc-package/psc-0.12.0-20181002/*/*/src/**/*.purs"]

gulp.task 'server', ->
  connect.server
    root: build,
    livereload: true

gulp.task 'assets', ->
  gulp.src asset_src
    .pipe gulp.dest("#{build}assets")
    .pipe connect.reload()

gulp.task 'html', ->
  gulp.src html_src
    .pipe gulp.dest(build)
    .pipe connect.reload()

gulp.task 'psc', ->
  purescript.compile(src: purs_src)

gulp.task 'psc-bundle', ['psc'], ->
  purescript.bundle(
    src: "./output/**/*.js",
    output: "#{build}js/main.js",
    module: "Main",
    main: "Main")

gulp.task 'browserify', ['psc-bundle'], ->
  browserify("#{build}js/main.js")
    .bundle()
    .pipe source('main.js')
    .pipe buffer()
    .pipe gulp.dest("#{build}js/")
    .pipe connect.reload()

gulp.task 'psci', (f) ->
  process.spawn('purs', ["repl"].concat(purs_src), stdio: 'inherit')
    .on('close', f)

gulp.task 'dotpsci', ->
  purescript.psci(src: purs_src)
    .pipe gulp.dest(".")

gulp.task 'watch', ->
  gulp.watch asset_src, ['assets']
  gulp.watch sass_src, ['sass']
  gulp.watch html_src, ['html']
  gulp.watch purs_src, ['psc-bundle']

gulp.task 'build', ['assets', 'html', 'psc-bundle']
gulp.task 'default', ['build', 'server', 'watch']

