const json = require('@rollup/plugin-json');
const { nodeResolve } = require('@rollup/plugin-node-resolve');
const replace = require('@rollup/plugin-replace');
const { globSync } = require('glob');
const commonjs = require('@rollup/plugin-commonjs');
const { babel } = require('@rollup/plugin-babel');
const css = require('rollup-plugin-import-css');
const url = require('@rollup/plugin-url');
const vue = require('@vitejs/plugin-vue2');
const copy = require('rollup-plugin-copy');
const terser = require('@rollup/plugin-terser');

function mapDirectory(file) {
  return file.replace('content/', 'public/');
}

// Global assets are copied here.
const vendorDir = './public/assets/vendor';

module.exports = globSync('content/frontend/**/*.js').map((file) => ({
  input: file,
  output: {
    file: mapDirectory(file),
    format: 'iife',
    name: file,
    inlineDynamicImports: true,
    globals: {
      vue: 'Vue',
      jquery: '$',
    },
  },
  external: ['vue', 'jquery'],
  cache: true,
  plugins: [
    nodeResolve({ browser: true, preferBuiltins: false }),
    commonjs(),
    vue(),
    url({
      destDir: 'public/assets/images',
      publicPath: '/assets/images/',
      fileName: 'icons.svg',
    }),
    babel({
      exclude: 'node_modules/**',
      babelHelpers: 'bundled',
    }),
    json(),
    css(),
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
          dest: vendorDir,
        },
        {
          src: './node_modules/vue/dist/vue.min.js',
          dest: vendorDir,
        },
        {
          src: './node_modules/lunr/lunr.min.js',
          dest: vendorDir,
        },
        {
          src: './node_modules/jquery/dist/jquery.slim.min.js',
          dest: vendorDir,
        },
        {
          src: './node_modules/bootstrap/dist/js/bootstrap.bundle.min.js*',
          dest: vendorDir,
        },
        {
          src: './node_modules/@gitlab/ui/dist/utility_classes.css*',
          dest: vendorDir,
        },
        {
          src: './node_modules/@gitlab/ui/dist/index.css*',
          dest: vendorDir,
        },
        {
          src: './node_modules/@gitlab/fonts/gitlab-sans/GitLabSans.woff2',
          dest: vendorDir,
        },
        {
          src: './node_modules/@gitlab/fonts/jetbrains-mono/JetBrainsMono*',
          dest: vendorDir,
        },
      ],
    }),
  ],
}));
