var webpack = require('webpack')
var path = require('path')
var pkg = require('./package.json')
var CleanWebpackPlugin = require('clean-webpack-plugin')
var HtmlWebpackPlugin = require('html-webpack-plugin')

var DEV = process.env.NODE_ENV === 'development'
var PROD = process.env.NODE_ENV === 'production'

var entry = ['./src/index.js']
var outputPath = path.join(__dirname, 'build', pkg.name)
var publicPath = ''
var plugins = [
  new HtmlWebpackPlugin({
    title: pkg.name,
    inject: true,
    template: path.join(__dirname, 'src/index.html'),
  }),
  new webpack.optimize.OccurenceOrderPlugin(),
]

if (DEV) {
  console.log('Running webpack with DEVELOPMENT flag')

  entry.unshift('webpack-hot-middleware/client')
  plugins = plugins.concat([
    new webpack.HotModuleReplacementPlugin(),
    new webpack.NoErrorsPlugin(),
  ])
}

if (PROD) {
  console.log('Running webpack with PRODUCTION flag')

  plugins = plugins.concat([
    new CleanWebpackPlugin(['lib']),
    new webpack.optimize.DedupePlugin(),
    new webpack.DefinePlugin({
      'process.env': {
        'NODE_ENV': '"production"',
      },
    }),
    // new webpack.optimize.UglifyJsPlugin({compressor: {warnings: false}}),
  ])

  entry = ['./src/index']
  outputPath = path.join(__dirname, 'lib')
  publicPath = 'https://io.vtex.com.br/' + pkg.name + '/' + pkg.version + '/'
}

module.exports = {
  devtool: 'source-map',

  entry: entry,

  output: {
    path: outputPath,
    publicPath: publicPath,
    filename: pkg.name,
    library: pkg.name.replace(/\-|\./g, ''),
    libraryTarget: 'umd',
  },

  resolve: {
    extensions: ['', '.js'],
  },

  externals: {
    'jquery': 'jQuery',
  },

  eslint: {
    configFile: '.eslintrc',
  },

  module: {
    loaders: [
      {
        test: /\.js?$/,
        exclude: /node_modules/,
        loaders: ['babel', 'eslint'],
      },
    ],
  },

  plugins: plugins,

  watch: !PROD,

  quiet: true,
  noInfo: true,

  proxy: {
    '*': 'http://janus-edge.vtex.com.br/',
  },
}