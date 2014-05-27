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
markdox = require 'gulp-markdox'
noDebug = require 'gulp-strip-debug'

sys = require('sys')
exec = require('child_process').exec;

pkg = require './package.json'

version =
	complete: pkg.version
[version.major, version.minor, version.patch] = version.complete.split('.')

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
		.pipe replace(/VERSION_REPLACE/, "#{version.complete}")
		.pipe coffee().on('error', gutil.log)
		.pipe gulp.dest './build'

gulp.task 'dist-base', ['js', 'clean-dist'], ->
	gulp.src './build/*'
		.pipe noDebug()
		.pipe header("/* vtex.js #{version.complete} */\n")
		.pipe gulp.dest "./dist/#{version.major}"
		.pipe rename extname: ".min.js"
		.pipe uglify outSourceMap: true
		.pipe gulp.dest "./dist/#{version.major}"
	gulp.src './build/*'
		.pipe noDebug()
		.pipe concat("vtex.js")
		.pipe gulp.dest "./dist/#{version.major}"
		.pipe header("/* vtex.js #{version.major} */\n")
		.pipe rename extname: '.min.js'
		.pipe uglify outSourceMap: true
		.pipe gulp.dest "./dist/#{version.major}"

gulp.task 'dist', ['dist-base'], ->
	gulp.src "./dist/#{version.major}/*"
		.pipe gulp.dest "./dist/#{version.major}.#{version.minor}"

gulp.task 'vtex_deploy', ->
	puts = (error, stdout, stderr) -> sys.puts(stdout)
	exec("AWS_CONFIG_FILE=/.aws-config-front aws s3 sync --size-only #{pkg.deploy} s3://vtex-io/#{pkg.name}/", puts)

gulp.task 'watch', ->
  gulp.watch './src/*.coffee', ['js']

gulp.task 'default', ['js', 'watch']