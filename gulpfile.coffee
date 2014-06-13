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
noDebug = require 'gulp-strip-debug'

sys = require('sys')
exec = require('child_process').exec;

pkg = require './package.json'


gulp.task 'clean-build', ->
	gulp.src './build/*', read: false
		.pipe clean()

gulp.task 'clean-dist', ->
	gulp.src './dist/*', read: false
		.pipe clean()

gulp.task 'clean-doc', ->
	gulp.src './doc/*', read: false
		.pipe clean()


gulp.task 'js', ['clean-build'], ->
	gulp.src './src/*.coffee'
		.pipe replace(/VERSION_REPLACE/, "#{pkg.version}")
		.pipe coffee().on('error', gutil.log)
		.pipe gulp.dest './build'

gulp.task 'dist', ['js', 'clean-dist'], ->
	gulp.src './package.json'
		.pipe gulp.dest "./dist/#{pkg.version}"
	gulp.src './build/*'
		.pipe noDebug()
		.pipe header "/*! vtex.js #{pkg.version} */\n"
		.pipe gulp.dest "./dist/#{pkg.version}"
		.pipe rename extname: ".min.js"
		.pipe uglify outSourceMap: true, preserveComments: 'some'
		.pipe gulp.dest "./dist/#{pkg.version}"
	gulp.src './build/*'
		.pipe noDebug()
		.pipe concat "vtex.js"
		.pipe header "/*! vtex.js #{pkg.version} */\n"
		.pipe gulp.dest "./dist/#{pkg.version}"
		.pipe rename extname: '.min.js'
		.pipe uglify outSourceMap: true, preserveComments: 'some'
		.pipe gulp.dest "./dist/#{pkg.version}"


gulp.task 'vtex_deploy', ->
	puts = (error, stdout, stderr) -> sys.puts(stdout)
	exec("AWS_CONFIG_FILE=/.aws-config-front aws s3 sync --size-only #{pkg.deploy} s3://vtex-io/#{pkg.name}/", puts)

gulp.task 'watch', ->
  gulp.watch './src/*.coffee', ['js']

gulp.task 'default', ['js', 'watch']