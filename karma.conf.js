module.exports = function(config) {
  return config.set({
    browsers: ['PhantomJS'],
    frameworks: ['mocha', 'chai'],
    files: [
      'spec/lib/jquery.js',
      'spec/lib/jquery.mockjax.js',
      'spec/mock/*.js',
      'lib/vtex.js',
      'spec/*.js',
    ],
    reporters: ['mocha'],
    client: {
      mocha: {
        ui: 'bdd',
      },
    },
  })
}
