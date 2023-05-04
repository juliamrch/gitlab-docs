const setupFilesAfterEnv = ['<rootDir>/spec/frontend/jest.overrides.js'];

const USE_VUE_3 = process.env.VUE_VERSION === '3';
const VUE_JEST_TRANSFORMER = USE_VUE_3 ? '@vue/vue3-jest' : '@vue/vue2-jest';

const customModuleNameMappers = {};
const extraJestConfig = {};

if (USE_VUE_3) {
  global.console.log('Using Vue.js 3');

  setupFilesAfterEnv.unshift('<rootDir>/spec/frontend/jest_setup_vue3_compat.js');
  Object.assign(customModuleNameMappers, {
    '^vue$': '@vue/compat',
    '^@vue/test-utils$': '@vue/test-utils-vue3',
  });
  Object.assign(extraJestConfig, {
    globals: {
      'vue-jest': {
        compilerOptions: {
          compatConfig: {
            MODE: 2,
          },
        },
      },
    },
  });
}

module.exports = {
  ...extraJestConfig,
  testMatch: ['<rootDir>/spec/frontend/**/**/*_spec.js'],
  moduleFileExtensions: ['js', 'json', 'vue'],
  moduleNameMapper: {
    '^~(/.*)$': '<rootDir>/content/frontend$1',
    '\\.(css|less|sass|scss)$': '<rootDir>/spec/frontend/__mocks__/style_mock.js',
    ...customModuleNameMappers,
  },
  cacheDirectory: '<rootDir>/tmp/cache/jest',
  restoreMocks: true,
  transform: {
    '^.+\\.js$': 'babel-jest',
    '^.+\\.vue$': VUE_JEST_TRANSFORMER,
    '^.+\\.svg$': VUE_JEST_TRANSFORMER,
  },
  transformIgnorePatterns: [
    'node_modules/(?!(@gitlab/(ui|svgs)|bootstrap-vue|vue-instantsearch|instantsearch.js)/)',
  ],
  snapshotSerializers: [
    '<rootDir>/spec/frontend/html_string_serializer.js',
    '<rootDir>/spec/frontend/clean_html_element_serializer.js',
  ],
  setupFilesAfterEnv,
};
