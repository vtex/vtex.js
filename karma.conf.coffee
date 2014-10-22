module.exports = (config) ->
  config.set
    browsers: ['PhantomJS']
    frameworks: ['mocha', 'chai']
    files: [
      'spec/lib/jquery.js'
      'spec/lib/jquery.mockjax.js'
      'spec/mock/*.coffee'
      'src/*.coffee'
      'spec/*.coffee'
    ]
    client:
      mocha:
        ui: 'tdd'
    preprocessors:
      '**/*.coffee': ['coffee']
