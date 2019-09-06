GruntVTEX = require 'grunt-vtex'

module.exports = (grunt) ->
  pkg = grunt.file.readJSON 'package.json'

  replaceMap = {}

  config = GruntVTEX.generateConfig grunt, pkg,
    replaceMap: replaceMap

  config.coffee.main.files = [
    expand: true
    cwd: 'src'
    src: ['**/*.coffee']
    dest: "build/<%= relativePath %>/"
    rename: (path, filename) ->
      path + filename.replace("coffee", "js")
  ]

  config.concat =
    main:
      files:
        'build/<%=relativePath%>/vtex.js': [
          'build/<%= relativePath %>/extended-ajax.js'
          'build/<%= relativePath %>/catalog.js'
          'build/<%= relativePath %>/checkout.js'
        ]

  config.uglify =
    main:
      files: [
        expand: true
        cwd: 'build/<%=relativePath%>/'
        src: '*.js'
        dest: 'build/<%=relativePath%>/'
        rename: (dest, src) -> dest + '/' + src.replace('.js', '.min.js')
      ]
      options:
        sourceMap: true

  config.copy.latest =
    files: [
      expand: true
      cwd: "build/<%= relativePath %>/"
      src: ['**']
      dest: "#{pkg.deploy}/latest"
    ]

  config.watch.coffee.files = ['src/*.coffee']

  tasks =
  # Building block tasks
    build: ['clean', 'copy:pkg', 'coffee', 'concat']
    min: ['uglify'] # minifies files
  # Deploy tasks
    dist: ['build', 'min', 'copy:deploy', 'copy:latest'] # Dist - minifies files
    test: []
    vtex_deploy: ['shell:cp']
  # Development tasks
    dev: ['nolr', 'build', 'min', 'watch']
    default: ['dev']

  # Project configuration.
  grunt.initConfig config
  grunt.loadNpmTasks name for name of pkg.devDependencies when name[0..5] is 'grunt-' and name isnt 'grunt-vtex'
  grunt.registerTask taskName, taskArray for taskName, taskArray of tasks
