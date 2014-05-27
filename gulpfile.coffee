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
knox    = require 'knox'
Deploy  = require 'deploy-s3'

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

gulp.task 'dist-mmp', ['js', 'clean-dist'], ->
	gulp.src './build/*'
		.pipe noDebug()
		.pipe header("/* vtex.js #{version.complete} */\n")
		.pipe gulp.dest "./dist/#{version.complete}"
		.pipe rename extname: ".min.js"
		.pipe uglify outSourceMap: true
		.pipe gulp.dest "./dist/#{version.complete}"
	gulp.src './build/*'
		.pipe noDebug()
		.pipe concat("vtex.js")
		.pipe gulp.dest "./dist/#{version.complete}"
		.pipe header("/* vtex.js #{version.complete} */\n")
		.pipe rename extname: '.min.js'
		.pipe uglify outSourceMap: true
		.pipe gulp.dest "./dist/#{version.complete}"

gulp.task 'dist', ['dist-mmp'], ->
	gulp.src "./dist/#{version.complete}/*"
		.pipe gulp.dest "./dist/#{version.major}"
		.pipe gulp.dest "./dist/#{version.major}.#{version.minor}"

gulp.task 'vtex_deploy', (cb) ->
	credentials = require './credentials.json'
	credentials.bucket = 'vtex-io'
	client = knox.createClient credentials
	deployer = new Deploy(pkg, client, dryrun: false)
	deployer.deploy().then ->
		cb()
	, null, console.log
	return undefined

gulp.task 'watch', ->
  gulp.watch './src/*.coffee', ['js']

gulp.task 'default', ['js', 'watch']