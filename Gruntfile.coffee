GruntVTEX = require 'grunt-vtex'

module.exports = (grunt) ->
  pkg = grunt.file.readJSON 'package.json'

  replaceMap = {}

  config = GruntVTEX.generateConfig grunt, pkg,
    relativePath: '/'
    replaceMap: replaceMap

  config.coffee.main.files = [
    expand: true
    cwd: 'src'
    src: ['**/*.coffee']
    dest: "build/"
    rename: (path, filename) ->
      path + filename.replace("coffee", "js")
  ]

  config.concat =
    main:
      files:
        'build/vtex.js': ['build/*.js']

  config.uglify =
    main:
      files: [
        expand: true
        cwd: 'build/'
        src: '*.js'
        dest: 'build'
        rename: (dest, src) -> dest + '/' + src.replace('.js', '.min.js')
      ]
      options:
        sourceMap: true

  tasks =
  # Building block tasks
    build: ['clean', 'copy:pkg', 'coffee', 'concat']
    min: ['uglify'] # minifies files
  # Deploy tasks
    dist: ['build', 'min', 'copy:deploy'] # Dist - minifies files
    test: []
    vtex_deploy: ['shell:cp', 'shell:cp_br']
  # Development tasks
    default: ['build', 'watch']

  # Project configuration.
  grunt.initConfig config
  grunt.loadNpmTasks name for name of pkg.devDependencies when name[0..5] is 'grunt-' and name isnt 'grunt-vtex'
  grunt.registerTask taskName, taskArray for taskName, taskArray of tasks