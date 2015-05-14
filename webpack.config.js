// require('coffee-script/register');
// module.exports = require("./webpack.config.coffee");

module.exports = {
  entry: './js/cjsx/main.cjsx',
  watch: true,
  debug: true,
  devtool: "inline-source-map",
  output: {
    filename: 'bundle.js',
    path: __dirname
  },
  module: {
    loaders: [
      { test: /\.cjsx$/, loader: 'coffee-jsx-loader' },
      { test: /\.coffee$/, loader: 'coffee-loader' },
      { test: /\.styl$/, loader: 'stylus' }
    ]
  }
};

