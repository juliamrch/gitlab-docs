const inject = require('@rollup/plugin-inject');
const json = require('@rollup/plugin-json');
const { nodeResolve } = require('@rollup/plugin-node-resolve');
const replace = require('@rollup/plugin-replace');
const { globSync } = require('glob');
const commonjs = require('@rollup/plugin-commonjs');
const { babel } = require('@rollup/plugin-babel');
const importResolver = require('rollup-plugin-import-resolver');
const css = require('rollup-plugin-import-css');
const url = require('@rollup/plugin-url');
const vue = require('rollup-plugin-vue');
const copy = require('rollup-plugin-copy');
const { terser } = require('rollup-plugin-terser');

function mapDirectory(file) {
  return file.replace('content/', 'public/');
}

module.exports = globSync('content/frontend/**/*.js').map((file) => ({
  input: file,
  output: {
    file: mapDirectory(file),
    format: 'iife',
    name: file,
    inlineDynamicImports: true,
  },
  cache: true,
  plugins: [
    nodeResolve({ browser: true, preferBuiltins: false }),
    commonjs({
      requireReturnsDefault: 'preferred',
    }),
    vue(),
    url({
      destDir: 'public/assets/images',
      publicPath: '/assets/images/',
      fileName: 'icons.svg',
    }),
    inject({
      exclude: 'node_modules/**',
    }),
    babel({
      exclude: 'node_modules/**',
      babelHelpers: 'bundled',
    }),
    json(),
    css(),
    importResolver({
      alias: {
        vue: './node_modules/vue/dist/vue.esm.browser.min.js',
      },
    }),
    replace({
      preventAssignment: true,
      'process.env.NODE_ENV': JSON.stringify('production'),
    }),
    terser(),
    copy({
      copyOnce: true,
      hook: 'closeBundle',
      targets: [
        {
          src: './node_modules/mermaid/dist/mermaid.min.js*',
          dest: './public/assets/javascripts/vendor',
        },
      ],
    }),
  ],
}));
