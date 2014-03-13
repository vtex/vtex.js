spawn   = require('child_process').spawn
fs      = require 'fs'
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

readJson = require('jsonfile').readFileSync
pkg = readJson 'package.json'


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
	gulp.src './build/*'
		.pipe noDebug()
		.pipe header("/* vtex.js #{pkg.version} */\n")
		.pipe gulp.dest './dist'
		.pipe rename extname: ".min.js"
		.pipe uglify outSourceMap: true
		.pipe gulp.dest './dist'
	gulp.src './build/*'
		.pipe noDebug()
		.pipe concat("vtex.js")
		.pipe gulp.dest './dist'
		.pipe header("/* vtex.js #{pkg.version} */\n")
		.pipe rename extname: '.min.js'
		.pipe uglify outSourceMap: true
		.pipe gulp.dest './dist'


gulp.task 'doc', ['clean-doc'], ->
	gulp.src './src/*'
		.pipe markdox()
		.pipe concat 'doc.md'
		.pipe gulp.dest('./doc')


gulp.task 'vtex_deploy', (cb) ->
	credentials = JSON.parse fs.readFileSync '/credentials.json'
	credentials.bucket = 'vtex-io'
	client = knox.createClient credentials
	deployer = new Deploy(pkg, client, dryrun: false)
	deployer.deploy().then ->
		cb()
	, null, console.log
	return undefined


gulp.task 'default', ['js'], ->
	gulp.watch './src/*.coffee', ->
		gulp.run 'clean-build', 'js'
