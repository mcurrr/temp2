gulp = require 'gulp'
plumber = require 'gulp-plumber'
cjsx = require 'gulp-cjsx'
gulpWebpack = require 'gulp-webpack'
webpackConfig = require './webpack.config.js'
stylus = require 'gulp-stylus'

gulp.task 'stylus', ->
  gulp.src './css/styl/custom.styl'
  .pipe(stylus())
  .pipe(gulp.dest './css/')

gulp.task 'gulpWebpack', ->
  gulp.src './js/cjsx/main.cjsx'
  .pipe(gulpWebpack webpackConfig)
  .pipe(gulp.dest './js/')

gulp.task 'watch', ->
  gulp.watch './js/cjsx/*.cjsx', ['gulpWebpack']
  gulp.watch './css/styl/*.styl', ['stylus']

gulp.task 'default', ['watch', 'gulpWebpack', 'stylus']