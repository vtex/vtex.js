module.exports = (config) ->
  config.set
    browsers: ['PhantomJS']
    frameworks: ['mocha', 'chai']
    files: [
      'spec/lib/jquery.js'
      'spec/lib/jquery.mockjax.js'
      'spec/mock/*.coffee'
      'src/catalog.coffee'
      'src/extended-ajax.coffee'
      'src/checkout.coffee'
      'spec/*.coffee'
    ]
    reporters: ['mocha']
    client:
      mocha:
        ui: 'bdd'
    preprocessors:
      '**/*.coffee': ['coffee']
