const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');

/** @type {import('webpack').Configuration} */
const mainConfig = {
  mode: 'production',
  target: 'electron-main',
  entry: path.resolve(__dirname, 'src/main/main.ts'),
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'main.js',
    clean: true,
  },
  resolve: { extensions: ['.ts', '.tsx', '.js'] },
  module: {
    rules: [
      { test: /\.tsx?$/, use: 'ts-loader', exclude: /node_modules/ },
    ],
  },
};

/** @type {import('webpack').Configuration} */
const preloadConfig = {
  mode: 'production',
  target: 'electron-preload',
  entry: path.resolve(__dirname, 'src/preload/preload.ts'),
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'preload.js',
  },
  resolve: { extensions: ['.ts', '.tsx', '.js'] },
  module: {
    rules: [
      { test: /\.tsx?$/, use: 'ts-loader', exclude: /node_modules/ },
    ],
  },
};

/** @type {import('webpack').Configuration} */
const rendererConfig = {
  mode: 'production',
  target: 'web',
  entry: path.resolve(__dirname, 'src/renderer/index.tsx'),
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'renderer.js',
  },
  resolve: { extensions: ['.ts', '.tsx', '.js'] },
  module: {
    rules: [
      { test: /\.tsx?$/, use: 'ts-loader', exclude: /node_modules/ },
      { test: /\.css$/, use: ['style-loader', 'css-loader', 'postcss-loader'] },
    ],
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: path.resolve(__dirname, 'src/renderer/index.html'),
    }),
  ],
};

module.exports = [mainConfig, preloadConfig, rendererConfig];
