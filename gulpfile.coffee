gulp    = require 'gulp'
gutil   = require 'gulp-util'
clean   = require 'gulp-clean'
watch   = require 'gulp-watch'
coffee  = require 'gulp-coffee'
replace = require 'gulp-replace'
uglify  = require 'gulp-uglify'
rename  = require 'gulp-rename'
concat  = require 'gulp-concat'
header  = require 'gulp-header'

readJson = require('jsonfile').readFileSync
pkg = readJson 'package.json'


gulp.task 'clean', ->
	gulp.src './build/*', read: false
		.pipe clean()
	gulp.src './dist/*', read: false
		.pipe clean()

gulp.task 'js', ['clean'], ->
	gulp.src './src/*.coffee'
		.pipe replace(/VERSION_REPLACE/, "#{pkg.version}")
		.pipe coffee().on('error', gutil.log)
		.pipe gulp.dest './build'

gulp.task 'dist', ['js'], ->
	gulp.src './build/*'
		.pipe uglify()
		.pipe concat('vtex-' + pkg.version + '.min.js')
		.pipe header('/* vtex.js <%= version %> */\n', pkg)
		.pipe gulp.dest './dist'

gulp.task 'default', ['js'], ->
	gulp.watch './src/*.coffee', ->
		gulp.run 'clean', 'js'
